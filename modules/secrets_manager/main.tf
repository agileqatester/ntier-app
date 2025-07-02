resource "aws_secretsmanager_secret" "rds" {
  name        = "${var.name_prefix}-rds-credentials"
  description = "Credentials for RDS DB instance"

  tags = {
    Name = "${var.name_prefix}-rds-secret"
  }
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.db_username,
    password = var.db_password
  })
}