resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.project_name}-website-${random_id.bucket_suffix.hex}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Project = var.project_name
    Purpose = "Website Hosting"
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "AllowPublicRead",
        Effect: "Allow",
        Principal = "*",
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}