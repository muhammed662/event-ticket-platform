data "aws_caller_identity" "current" {}


data "archive_file" "backend" {
  type        = "zip"
  source_dir  = "${path.module}/../backend"
  output_path = "${path.module}/build/backend.zip"

  excludes = [
    ".pytest_cache",
    "app/__pycache__",
    "tests/__pycache__",
  ]
}


resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}-artifacts"

  force_destroy = true

  tags = {
    Name = "${var.project_name}-artifacts"
  }
}


resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_object" "backend" {
  bucket = aws_s3_bucket.artifacts.id
  key    = "backend/backend.zip"

  source      = data.archive_file.backend.output_path
  source_hash = data.archive_file.backend.output_base64sha256

  content_type = "application/zip"
}