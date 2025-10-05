resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.name_prefix}-vpc"
    Environment = var.name_prefix
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.name_prefix}-igw"
    Environment = var.name_prefix
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.name_prefix}-public-${count.index + 1}"
    Environment = var.name_prefix
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.name_prefix}-private-${count.index + 1}"
    Environment = var.name_prefix
  }
}

resource "aws_eip" "nat" {
  count = var.nat_mode == "gateway" ? length(var.azs) : 0

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count         = var.nat_mode == "gateway" ? length(var.azs) : 0
  allocation_id = var.nat_mode == "gateway" ? aws_eip.nat[count.index].id : null
  subnet_id     = var.nat_mode == "gateway" ? aws_subnet.public[count.index].id : null

  tags = var.nat_mode == "gateway" ? {
    Name        = "${var.name_prefix}-nat-${count.index + 1}"
    Environment = var.name_prefix
  } : {}
}

// NAT instance (lower-cost option for dev/non-prod). Created only when nat_mode == "instance".
resource "aws_eip" "nat_instance" {
  count = var.nat_mode == "instance" ? 1 : 0
  domain = "vpc"
}

resource "aws_security_group" "nat_instance" {
  count = var.nat_mode == "instance" ? 1 : 0

  name        = "${var.name_prefix}-nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.this.id

  # Allow traffic only from the private subnets to the NAT instance
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
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
  instance_type = "t3a.nano"
  subnet_id     = aws_subnet.public[0].id
  associate_public_ip_address = true
  vpc_security_group_ids = var.nat_mode == "instance" ? [aws_security_group.nat_instance[0].id] : []
  # NAT instances must have source/destination checks disabled
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


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.name_prefix}-rt-public"
    Environment = var.name_prefix
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.name_prefix}-rt-private-${count.index + 1}"
    Environment = var.name_prefix
  }
}

// Routes for private subnets: point to NAT gateway (per AZ) or to single NAT instance depending on nat_mode
resource "aws_route" "private_nat_gateway" {
  count                  = var.nat_mode == "gateway" ? length(var.azs) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route" "private_nat_instance" {
  count                  = var.nat_mode == "instance" ? length(var.azs) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  # For NAT instances, route traffic via the instance's primary network interface.
  # Use the primary_network_interface_id to avoid provider computed/managed instance_id conflicts.
  network_interface_id   = aws_instance.nat_instance[0].primary_network_interface_id
}

resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name_prefix}-vpc-endpoint-sg"
  description = "Allow HTTPS to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-vpc-endpoints-sg"
    Environment = var.name_prefix
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = aws_route_table.private[*].id
  vpc_endpoint_type = "Gateway"

  tags = {
    Name        = "${var.name_prefix}-vpce-s3"
    Environment = var.name_prefix
  }
}

resource "aws_vpc_endpoint" "kinesis_firehose" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.kinesis-firehose"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.name_prefix}-vpce-kinesis-firehose"
    Environment = var.name_prefix
  }
}

resource "aws_vpc_endpoint" "opensearch" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.es"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.name_prefix}-vpce-opensearch"
    Environment = var.name_prefix
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.name_prefix}-vpce-secretsmanager"
    Environment = var.name_prefix
  }
}
