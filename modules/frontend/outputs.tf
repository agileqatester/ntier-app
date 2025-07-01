output "frontend_bucket_name" {
  description = "S3 bucket used to host the frontend"
  value       = aws_s3_bucket.frontend.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "frontend_dns_fqdn" {
  description = "FQDN of the frontend app via Route53"
  value       = aws_route53_record.frontend_dns.fqdn
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.frontend.id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool App Client ID"
  value       = aws_cognito_user_pool_client.frontend.id
}

output "cognito_domain_name" {
  description = "Cognito domain name"
  value       = aws_cognito_user_pool_domain.frontend.domain
}
