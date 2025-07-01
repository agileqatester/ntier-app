output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways"
  value       = aws_nat_gateway.this[*].id
}

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value = {
    s3             = aws_vpc_endpoint.s3_gateway.id
    kinesis        = aws_vpc_endpoint.kinesis_firehose.id
    opensearch     = aws_vpc_endpoint.opensearch.id
    secretsmanager = aws_vpc_endpoint.secretsmanager.id
  }
}
