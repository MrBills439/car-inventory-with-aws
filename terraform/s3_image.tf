resource "aws_s3_bucket" "car_images" {
  bucket = "${var.project_name}-images-${random_id.bucket_suffix.hex}"

  tags = {
    Project = var.project_name
    Owner   = "Felix"
  }
}

# Public Access Block (optional for your use-case since images are public)
resource "aws_s3_bucket_public_access_block" "car_images_block" {
  bucket                  = aws_s3_bucket.car_images.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read of car images
resource "aws_s3_bucket_policy" "car_images_policy" {
  bucket = aws_s3_bucket.car_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.car_images.arn}/*"
        Principal = "*"
      }
    ]
  })
}

# NEW WAY: Versioning (no warnings)
resource "aws_s3_bucket_versioning" "car_images_versioning" {
  bucket = aws_s3_bucket.car_images.id

  versioning_configuration {
    status = "Disabled"
  }
}

# NEW WAY: Lifecycle rules (no warnings)
resource "aws_s3_bucket_lifecycle_configuration" "car_images_lifecycle" {
  bucket = aws_s3_bucket.car_images.id

  rule {
    id     = "abort-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
