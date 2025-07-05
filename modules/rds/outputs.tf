output "rds_primary_endpoint" {
  description = "Primary RDS instance endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "rds_replica_endpoint" {
  description = "Read replica RDS instance endpoint"
  value       = aws_db_instance.replica.endpoint
}

output "rds_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing RDS credentials"
  value       = aws_secretsmanager_secret.db.arn
}

output "rds_host" {
  value = aws_db_instance.primary.address
}

output "rds_endpoint" {
  description = "The endpoint of the primary RDS instance"
  value       = aws_db_instance.primary.endpoint
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}