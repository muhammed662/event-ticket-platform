locals {
  frontend_files = {
    "index.html" = {
      source       = "${path.module}/../frontend/index.html"
      content_type = "text/html"
    }

    "styles.css" = {
      source       = "${path.module}/../frontend/styles.css"
      content_type = "text/css"
    }

    "app.js" = {
      source       = "${path.module}/../frontend/app.js"
      content_type = "application/javascript"
    }
  }
}


resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}-frontend"

  force_destroy = true

  tags = {
    Name = "${var.project_name}-frontend"
  }
}


resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_object" "frontend" {
  for_each = local.frontend_files

  bucket = aws_s3_bucket.frontend.id
  key    = each.key
  source = each.value.source

  source_hash  = filebase64sha256(each.value.source)
  content_type = each.value.content_type
}