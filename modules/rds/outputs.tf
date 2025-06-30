output "rds_primary_endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "rds_replica_endpoint" {
  value = aws_db_instance.replica.endpoint
}

output "rds_credentials_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}