output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  description = "Security Group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "alb_fqdn" {
  description = "Fully qualified domain name (FQDN) for the ALB using Route 53"
  value       = aws_route53_record.alb_dns.fqdn
}
