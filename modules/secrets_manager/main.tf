resource "aws_secretsmanager_secret" "rds" {
  name        = "${var.name_prefix}-rds-credentials"
  description = "Credentials for RDS DB instance"

  tags = {
    Name = "${var.name_prefix}-rds-secret"
  }
}

resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
  })
}
