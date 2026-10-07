# bucket_prefix: S3 names are global across all AWS accounts. AWS adds a unique suffix to the prefix.
resource "aws_s3_bucket" "demo" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true # lets `terraform destroy` delete a non-empty bucket (demo only)

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "Session18"
  }
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
