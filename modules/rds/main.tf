resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-rds-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow Postgres access from EKS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
}

resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.name_prefix}/rds/db-credentials"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username,
    password = random_password.db.result
  })

  depends_on = [aws_secretsmanager_secret.db]
}

resource "aws_db_instance" "primary" {
  identifier              = "${var.name_prefix}-rds-primary"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  username                = var.db_username
  password                = random_password.db.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  multi_az                = true
  skip_final_snapshot     = true
  backup_retention_period = var.backup_retention_days
  preferred_backup_window = var.backup_window
  deletion_protection     = true
  publicly_accessible     = false
  storage_encrypted       = true

  tags = {
    Name = "${var.name_prefix}-rds-primary"
  }

  depends_on = [
    aws_db_subnet_group.this,
    aws_security_group.rds
  ]
}

resource "aws_db_instance" "replica" {
  identifier             = "${var.name_prefix}-rds-replica"
  engine                 = aws_db_instance.primary.engine
  instance_class         = var.instance_class
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  replicate_source_db    = aws_db_instance.primary.identifier
  skip_final_snapshot    = true

  tags = {
    Name = "${var.name_prefix}-rds-replica"
  }

  depends_on = [aws_db_instance.primary]
}
