output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "vpc_endpoint_ids" {
  value = {
    s3             = aws_vpc_endpoint.s3_gateway.id
    kinesis        = aws_vpc_endpoint.kinesis_firehose.id
    opensearch     = aws_vpc_endpoint.opensearch.id
    secretsmanager = aws_vpc_endpoint.secretsmanager.id
  }
}
