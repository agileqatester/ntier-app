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

locals {
  instance_architecture_map = {
    t2 = "x86_64"
    t3 = "x86_64"
    t3a = "x86_64"
    t4g = "arm64"
    m6g = "arm64"
    c6g = "arm64"
    r6g = "arm64"
  }

  instance_family = regex("^([a-z0-9]+)", var.instance_type)[0]
  architecture    = lookup(local.instance_architecture_map, local.instance_family, "x86_64") # default fallback
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = [
      local.architecture == "x86_64" ? "al2023-ami-*-x86_64" : "al2023-ami-*-arm64"
    ]
  }

  filter {
    name   = "architecture"
    values = [local.architecture]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "platform-details"
    values = ["Linux/UNIX"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = [ "gp3"]
  }
}

resource "tls_private_key" "local" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jumpbox" {
  key_name   = "${var.name_prefix}-jumpbox-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "jumpbox" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
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