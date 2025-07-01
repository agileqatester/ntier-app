resource "aws_s3_bucket" "logs" {
  bucket         = "${var.name_prefix}-logging-bucket"
  force_destroy  = true

  tags = {
    Name = "${var.name_prefix}-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_kinesis_stream" "log_stream" {
  name             = "${var.name_prefix}-log-stream"
  shard_count      = 1
  retention_period = 24

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Name = "${var.name_prefix}-log-stream"
  }
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/kinesisfirehose/${var.name_prefix}-firehose"
  retention_in_days = 7

  tags = {
    Name = "${var.name_prefix}-firehose-logs"
  }
}

resource "aws_opensearch_domain" "logs" {
  domain_name    = "${var.name_prefix}-logs"
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp3"
  }

  access_policies = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = var.firehose_role_arn
        },
        Action = "es:*",
        Resource = "arn:aws:es:${var.region}:${var.account_id}:domain/${var.name_prefix}-logs/*"
      }
    ]
  })

  vpc_options {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.security_group_id]
  }

  tags = {
    Name = "${var.name_prefix}-opensearch"
  }

  depends_on = [
    aws_kinesis_stream.log_stream,
    aws_s3_bucket.logs
  ]
}

resource "aws_kinesis_firehose_delivery_stream" "to_s3_and_es" {
  name        = "${var.name_prefix}-firehose"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.log_stream.arn
    role_arn           = var.firehose_role_arn
  }

  extended_s3_configuration {
    bucket_arn         = aws_s3_bucket.logs.arn
    role_arn           = var.firehose_role_arn
    compression_format = "GZIP"

    buffering_interval = 300
    buffering_size     = 10

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = "S3Delivery"
    }

    processing_configuration {
      enabled = false
    }
  }

  tags = {
    Name = "${var.name_prefix}-firehose"
  }

  depends_on = [
    aws_kinesis_stream.log_stream,
    aws_s3_bucket.logs,
    aws_cloudwatch_log_group.firehose
  ]
}
