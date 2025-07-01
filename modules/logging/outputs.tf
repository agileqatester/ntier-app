output "s3_bucket_name" {
  value = aws_s3_bucket.logs.id
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.log_stream.name
}

output "firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.to_s3_and_es.name
}

output "opensearch_endpoint" {
  value = aws_opensearch_domain.logs.endpoint
}
