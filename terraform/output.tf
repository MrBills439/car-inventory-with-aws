output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.cars.name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.car_images.bucket
}