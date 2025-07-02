resource "aws_wafv2_web_acl" "this" {
  name  = "${var.name_prefix}-waf"
  scope = var.scope  # "REGIONAL" for ALB, "CLOUDFRONT" for CDN

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-common"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Name = "${var.name_prefix}-waf"
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  count         = var.scope == "REGIONAL" ? 1 : 0
  resource_arn  = var.resource_arn
  web_acl_arn   = aws_wafv2_web_acl.this.arn
}