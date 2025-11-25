resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["Content-Type", "Authorization"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins     = ["*"]
    expose_headers    = []
    max_age           = 0
  }
}

# ---------------------------------------------------------
# INTEGRATIONS (all must use integration_method = "POST")
# ---------------------------------------------------------

# Create Car
resource "aws_apigatewayv2_integration" "create_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.create_car.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# List Cars
resource "aws_apigatewayv2_integration" "list_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list_cars.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Get Single Car
resource "aws_apigatewayv2_integration" "get_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_car.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Update Car
resource "aws_apigatewayv2_integration" "update_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.update_car.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Delete Car
resource "aws_apigatewayv2_integration" "delete_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.delete_car.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Upload Image
resource "aws_apigatewayv2_integration" "upload_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.upload_image.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# ---------------------------------------------------------
# ROUTES
# ---------------------------------------------------------
resource "aws_apigatewayv2_route" "create_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /cars"
  target    = "integrations/${aws_apigatewayv2_integration.create_integration.id}"
}

resource "aws_apigatewayv2_route" "list_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /cars"
  target    = "integrations/${aws_apigatewayv2_integration.list_integration.id}"
}

resource "aws_apigatewayv2_route" "get_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /cars/{carId}"
  target    = "integrations/${aws_apigatewayv2_integration.get_integration.id}"
}

resource "aws_apigatewayv2_route" "update_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /cars/{carId}"
  target    = "integrations/${aws_apigatewayv2_integration.update_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /cars/{carId}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_integration.id}"
}

resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /cars/upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_integration.id}"
}

# ---------------------------------------------------------
# PERMISSIONS (allow API Gateway to call Lambdas)
# ---------------------------------------------------------
resource "aws_lambda_permission" "apigw_create" {
  statement_id  = "AllowAPIGatewayInvokeCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_car.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_list" {
  statement_id  = "AllowAPIGatewayInvokeList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_cars.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_car.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_update" {
  statement_id  = "AllowAPIGatewayInvokeUpdate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_car.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_delete" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_car.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_upload" {
  statement_id  = "AllowAPIGatewayInvokeUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_image.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# ---------------------------------------------------------
# STAGE ($default)
# ---------------------------------------------------------
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

