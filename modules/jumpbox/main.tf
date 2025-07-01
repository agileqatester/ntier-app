resource "aws_key_pair" "jumpbox" {
  key_name   = "${var.name_prefix}-jumpbox-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "${var.name_prefix}-jumpbox-key"
  }
}

resource "aws_security_group" "jumpbox" {
  name        = "${var.name_prefix}-jumpbox-sg"
  description = "Allow SSH from my_ip and access to RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my_ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-jumpbox-sg"
  }
}

resource "aws_instance" "jumpbox" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  key_name                    = aws_key_pair.jumpbox.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jumpbox.id]

  user_data = templatefile("${path.module}/init.sh.tpl", {
    rds_secret_arn = var.rds_secret_arn,
    rds_host       = var.rds_host,
    db_name        = var.db_name
  })

  tags = {
    Name = "${var.name_prefix}-jumpbox"
  }

  depends_on = [aws_security_group.jumpbox, aws_key_pair.jumpbox]
}