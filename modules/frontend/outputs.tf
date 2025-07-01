output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "frontend_dns_fqdn" {
  value = aws_route53_record.frontend_dns.fqdn
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.frontend.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.frontend.id
}

output "cognito_domain_name" {
  value = aws_cognito_user_pool_domain.frontend.domain
}
