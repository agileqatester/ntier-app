resource "aws_cognito_user_pool" "frontend" {
  name = "${var.name_prefix}-user-pool"

  auto_verified_attributes = ["email"]

  username_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  tags = {
    Name = "${var.name_prefix}-cognito-user-pool"
  }
}

resource "aws_cognito_user_pool_client" "frontend" {
  name         = "${var.name_prefix}-app-client"
  user_pool_id = aws_cognito_user_pool.frontend.id
  generate_secret = false
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true
  callback_urls = [var.cognito_callback_url]
  logout_urls   = [var.cognito_logout_url]
  supported_identity_providers = ["COGNITO"]

}

resource "aws_cognito_user_pool_domain" "frontend" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.frontend.id
}

# existing S3 + CloudFront + Route53 + sync code remains unchanged

resource "aws_s3_bucket" "frontend" {
  bucket = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.name_prefix}-frontend-bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.frontend.iam_arn
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "OAI for frontend bucket"
}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3-frontend"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-frontend"

    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.name_prefix}-frontend-cdn"
  }
}

resource "aws_route53_record" "frontend_dns" {
  zone_id = var.route53_zone_id
  name    = var.subdomain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "null_resource" "frontend_deploy" {
  provisioner "local-exec" {
    command = "aws s3 sync ${var.frontend_build_dir} s3://${aws_s3_bucket.frontend.bucket}/ --delete"
  }

  triggers = {
    always_run = timestamp()
  }
}

# === Cognito Users and Groups ===
resource "aws_cognito_user" "admin" {
  user_pool_id = aws_cognito_user_pool.frontend.id
  username     = var.admin_email
  attributes = {
    email          = var.admin_email
    email_verified = true
  }
  temporary_password = var.admin_temp_password
  force_alias_creation = false
  message_action = "SUPPRESS"
}

resource "aws_cognito_group" "admin_group" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.frontend.id
  description  = "Admin access group"
  precedence   = 1
}

resource "aws_cognito_user_group_attachment" "admin_attachment" {
  user_pool_id = aws_cognito_user_pool.frontend.id
  username     = aws_cognito_user.admin.username
  groups       = [aws_cognito_group.admin_group.name]
}

# === ALB Listener Rule for Cognito Auth ===
resource "aws_lb_listener" "https_with_cognito" {
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.frontend.arn
      user_pool_client_id = aws_cognito_user_pool_client.frontend.id
      user_pool_domain    = aws_cognito_user_pool_domain.frontend.domain
      on_unauthenticated_request = "authenticate"
    }

    order = 1
  }

  default_action {
    type             = "forward"
    target_group_arn = var.alb_target_group_arn
  }
}