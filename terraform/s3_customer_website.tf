# Random suffix for bucket uniqueness
resource "random_id" "customer_bucket_suffix" {
  byte_length = 4
}

# Create the customer S3 bucket
resource "aws_s3_bucket" "customer_website" {
  bucket = "${var.project_name}-customer-website-${random_id.customer_bucket_suffix.hex}"

  force_destroy = true

  tags = {
    Project = var.project_name
    Purpose = "Customer Website Hosting"
  }
}

# Static website hosting configuration
resource "aws_s3_bucket_website_configuration" "customer_website_config" {
  bucket = aws_s3_bucket.customer_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Allow public access (required for website hosting)
resource "aws_s3_bucket_public_access_block" "customer_website_access" {
  bucket = aws_s3_bucket.customer_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Policy to allow public read
resource "aws_s3_bucket_policy" "customer_website_policy" {
  bucket = aws_s3_bucket.customer_website.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPublicRead",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.customer_website.arn}/*"
      }
    ]
  })
}

# Output the bucket name and website URL
output "customer_website_bucket" {
  value = aws_s3_bucket.customer_website.bucket
}

output "customer_website_url" {
  value = aws_s3_bucket_website_configuration.customer_website_config.website_endpoint
}
