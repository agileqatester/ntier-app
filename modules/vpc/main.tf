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

// NAT is provided by the nested nat module.
module "nat" {
  source           = "../nat"
  name_prefix      = var.name_prefix
  vpc_id           = aws_vpc.this.id
  public_subnet_ids = aws_subnet.public[*].id
  azs              = var.azs
  nat_mode         = var.nat_mode
  nat_instance_ami = var.nat_instance_ami
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
  nat_gateway_id         = module.nat.nat_gateway_ids[count.index]
}

resource "aws_route" "private_nat_instance" {
  count                  = var.nat_mode == "instance" ? length(var.azs) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat.nat_instance_primary_network_interface_id
}

resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

// Optional dedicated endpoint subnets (one per AZ). When provided, interface endpoints will be placed
// into these subnets instead of the private app subnets.
resource "aws_subnet" "endpoint" {
  count             = length(var.endpoint_subnet_cidrs) > 0 ? length(var.endpoint_subnet_cidrs) : 0
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.endpoint_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name        = "${var.name_prefix}-endpoint-${count.index + 1}"
    Environment = var.name_prefix
  }
}

// Endpoint SG is now owned by the security module. Use the provided endpoint_security_group_id or fall back
// to the original vpc_endpoints SG for backward compatibility.

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name_prefix}-vpc-endpoint-sg"
  description = "Allow HTTPS to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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
  subnet_ids          = length(var.endpoint_subnet_cidrs) > 0 ? aws_subnet.endpoint[*].id : aws_subnet.private[*].id
  security_group_ids  = [var.endpoint_security_group_id != "" ? var.endpoint_security_group_id : aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.name_prefix}-vpce-kinesis-firehose"
    Environment = var.name_prefix
  }
}

# Commented out for testing - OpenSearch endpoint not needed and service name varies by region
# resource "aws_vpc_endpoint" "opensearch" {
#   vpc_id              = aws_vpc.this.id
#   service_name        = "com.amazonaws.${var.region}.es"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = length(var.endpoint_subnet_cidrs) > 0 ? aws_subnet.endpoint[*].id : aws_subnet.private[*].id
#   security_group_ids  = [var.endpoint_security_group_id != "" ? var.endpoint_security_group_id : aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#
#   tags = {
#     Name        = "${var.name_prefix}-vpce-opensearch"
#     Environment = var.name_prefix
#   }
# }

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = length(var.endpoint_subnet_cidrs) > 0 ? aws_subnet.endpoint[*].id : aws_subnet.private[*].id
  security_group_ids  = [var.endpoint_security_group_id != "" ? var.endpoint_security_group_id : aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.name_prefix}-vpce-secretsmanager"
    Environment = var.name_prefix
  }
}

# Commented out - let jumpbox use internet directly for SSM
# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id              = aws_vpc.this.id
#   service_name        = "com.amazonaws.${var.region}.ssm"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = length(var.endpoint_subnet_cidrs) > 0 ? aws_subnet.endpoint[*].id : aws_subnet.public[*].id
#   security_group_ids  = [var.endpoint_security_group_id != "" ? var.endpoint_security_group_id : aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#
#   tags = {
#     Name        = "${var.name_prefix}-vpce-ssm"
#     Environment = var.name_prefix
#   }
# }
#
# resource "aws_vpc_endpoint" "ssmmessages" {
#   vpc_id              = aws_vpc.this.id
#   service_name        = "com.amazonaws.${var.region}.ssmmessages"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = length(var.endpoint_subnet_cidrs) > 0 ? aws_subnet.endpoint[*].id : aws_subnet.public[*].id
#   security_group_ids  = [var.endpoint_security_group_id != "" ? var.endpoint_security_group_id : aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#
#   tags = {
#     Name        = "${var.name_prefix}-vpce-ssmmessages"
#     Environment = var.name_prefix
#   }
# }
#
# resource "aws_vpc_endpoint" "ec2messages" {
#   vpc_id              = aws_vpc.this.id
#   service_name        = "com.amazonaws.${var.region}.ec2messages"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = length(var.endpoint_subnet_cidrs) > 0 ? aws_subnet.endpoint[*].id : aws_subnet.public[*].id
#   security_group_ids  = [var.endpoint_security_group_id != "" ? var.endpoint_security_group_id : aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#
#   tags = {
#     Name        = "${var.name_prefix}-vpce-ec2messages"
#     Environment = var.name_prefix
#   }
# }
