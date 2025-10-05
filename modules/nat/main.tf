// NAT module: supports nat_mode = "gateway" (per-AZ NAT gateways) or "instance" (single NAT instance)

resource "aws_eip" "nat" {
  count = var.nat_mode == "gateway" ? length(var.azs) : 0
  depends_on = []
}

resource "aws_nat_gateway" "this" {
  count         = var.nat_mode == "gateway" ? length(var.azs) : 0
  allocation_id = var.nat_mode == "gateway" ? aws_eip.nat[count.index].id : null
  subnet_id     = var.nat_mode == "gateway" ? var.public_subnet_ids[count.index] : null

  tags = var.nat_mode == "gateway" ? {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  } : {}
}

// NAT instance resources
resource "aws_eip" "nat_instance" {
  count = var.nat_mode == "instance" ? 1 : 0
  domain = "vpc"
}

resource "aws_security_group" "nat_instance" {
  count = var.nat_mode == "instance" ? 1 : 0

  name        = "${var.name_prefix}-nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-nat-instance-sg"
  }
}

resource "aws_instance" "nat_instance" {
  count         = var.nat_mode == "instance" ? 1 : 0
  ami           = var.nat_instance_ami != "" ? var.nat_instance_ami : data.aws_ami.nat_instance.id
  instance_type = var.nat_instance_type
  subnet_id     = var.public_subnet_ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids = var.nat_mode == "instance" ? [aws_security_group.nat_instance[0].id] : []
  source_dest_check = false

  tags = {
    Name = "${var.name_prefix}-nat-instance"
  }
}

data "aws_ami" "nat_instance" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
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
    values = ["gp3"]
  }
}
