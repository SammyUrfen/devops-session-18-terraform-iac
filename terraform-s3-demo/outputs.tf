output "bucket_name" {
  description = "Final bucket name (prefix + AWS suffix)."
  value       = aws_s3_bucket.demo.bucket
}

output "bucket_arn" {
  description = "Bucket ARN."
  value       = aws_s3_bucket.demo.arn
}

output "bucket_region" {
  description = "Bucket region."
  value       = aws_s3_bucket.demo.region
}
