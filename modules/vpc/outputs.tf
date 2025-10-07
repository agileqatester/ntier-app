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
  value       = try(module.nat.nat_gateway_ids, [])
}

output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value = {
    s3             = aws_vpc_endpoint.s3_gateway.id
    kinesis        = aws_vpc_endpoint.kinesis_firehose.id
    # opensearch     = aws_vpc_endpoint.opensearch.id  # Commented out for testing
    secretsmanager = aws_vpc_endpoint.secretsmanager.id
  }
}

output "endpoint_security_group_id" {
  description = "Security group used for interface VPC endpoints (if created)"
  value       = var.endpoint_security_group_id != "" ? var.endpoint_security_group_id : aws_security_group.vpc_endpoints.id
}

output "endpoint_subnet_ids" {
  description = "IDs of endpoint subnets (when provided)"
  value       = length(var.endpoint_subnet_cidrs) > 0 ? aws_subnet.endpoint[*].id : []
}
