output "s3_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = aws_s3_bucket.logs.id
}

output "kinesis_stream_name" {
  description = "Name of the Kinesis stream used for logs"
  value       = aws_kinesis_stream.log_stream.name
}

output "firehose_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.to_s3_and_es.name
}

output "opensearch_endpoint" {
  description = "Endpoint URL of the OpenSearch domain"
  value       = aws_opensearch_domain.logs.endpoint
}
