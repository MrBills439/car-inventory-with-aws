data "archive_file" "create_car_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/create_car"
  output_path = "${path.module}/../build/create_car.zip"
}

data "archive_file" "list_cars_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/list_cars"
  output_path = "${path.module}/../build/list_cars.zip"
}

data "archive_file" "get_car_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/get_car"
  output_path = "${path.module}/../build/get_car.zip"
}

data "archive_file" "update_car_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/update_car"
  output_path = "${path.module}/../build/update_car.zip"
}

data "archive_file" "delete_car_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/delete_car"
  output_path = "${path.module}/../build/delete_car.zip"
}

data "archive_file" "upload_image_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/upload_image"
  output_path = "${path.module}/../build/upload_image.zip"
}

resource "aws_lambda_function" "create_car" {
  filename         = data.archive_file.create_car_zip.output_path
  function_name    = "${var.project_name}-create-car"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.create_car_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cars.name
      BUCKET     = aws_s3_bucket.car_images.bucket
    }
  }
}

resource "aws_lambda_function" "list_cars" {
  filename         = data.archive_file.list_cars_zip.output_path
  function_name    = "${var.project_name}-list-cars"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.list_cars_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cars.name
      BUCKET     = aws_s3_bucket.car_images.bucket
    }
  }
}

resource "aws_lambda_function" "get_car" {
  filename         = data.archive_file.get_car_zip.output_path
  function_name    = "${var.project_name}-get-car"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.get_car_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cars.name
      BUCKET     = aws_s3_bucket.car_images.bucket
    }
  }
}

resource "aws_lambda_function" "update_car" {
  filename         = data.archive_file.update_car_zip.output_path
  function_name    = "${var.project_name}-update-car"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.update_car_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cars.name
      BUCKET     = aws_s3_bucket.car_images.bucket
    }
  }
}

resource "aws_lambda_function" "delete_car" {
  filename         = data.archive_file.delete_car_zip.output_path
  function_name    = "${var.project_name}-delete-car"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.delete_car_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cars.name
      BUCKET     = aws_s3_bucket.car_images.bucket
    }
  }
}

resource "aws_lambda_function" "upload_image" {
  filename         = data.archive_file.upload_image_zip.output_path
  function_name    = "${var.project_name}-upload-image"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.upload_image_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cars.name
      BUCKET     = aws_s3_bucket.car_images.bucket
    }
  }
}