resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "car_images" {
  bucket = "${var.project_name}-images-${random_id.bucket_suffix.hex}"
  acl    = "public-read"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    id      = "prevent-delete"
    enabled = true

    abort_incomplete_multipart_upload_days = 7
  }

  tags = {
    Project = var.project_name
    Owner   = "Felix"
  }
}

resource "aws_s3_bucket_public_access_block" "car_images_block" {
  bucket = aws_s3_bucket.car_images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read policy for objects (images). If you want images private, remove this.
resource "aws_s3_bucket_policy" "car_images_policy" {
  bucket = aws_s3_bucket.car_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.car_images.arn}/*"
      }
    ]
  })
}