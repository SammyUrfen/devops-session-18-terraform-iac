variable "aws_region" {
  type        = string
  description = "AWS region for the bucket."
  default     = "ap-south-1"
}

variable "bucket_prefix" {
  type        = string
  description = "Bucket name prefix. AWS appends a unique suffix, so the name never clashes globally."
  default     = "bibek-s18-demo-"
}

variable "environment" {
  type        = string
  description = "Value for the Environment tag."
  default     = "dev"
}
