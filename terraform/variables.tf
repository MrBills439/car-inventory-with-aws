variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.10"
}

variable "project_name" {
  type    = string
  default = "car-inventory"
}