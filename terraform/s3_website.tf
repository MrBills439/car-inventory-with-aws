resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.project_name}-website-${random_id.bucket_suffix.hex}"

  tags = {
    Project = var.project_name
    Purpose = "Website Hosting"
  }
}

# Website Hosting configuration (NEW format)
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Public Access Block (must be disabled for website hosting)
resource "aws_s3_bucket_public_access_block" "website_public_block" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read policy (needed for website files)
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "PublicReadSite",
        Effect : "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

# NEW WAY: Versioning
resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.website_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

# NEW WAY: Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "website_lifecycle" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    id     = "abort-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
