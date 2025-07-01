output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "alb_fqdn" {
  value = aws_route53_record.alb_dns.fqdn
}