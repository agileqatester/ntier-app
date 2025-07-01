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
