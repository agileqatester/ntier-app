output "rds_secret_arn" {
  description = "ARN of the RDS secret"
  value       = aws_secretsmanager_secret.rds.arn
}

output "rds_secret_name" {
  description = "Name of the RDS secret"
  value       = aws_secretsmanager_secret.rds.name
}