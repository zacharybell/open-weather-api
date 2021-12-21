terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "zacharybell-terraform-state"
    key            = "open-weather-api.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  prefix = "weather-${terraform.workspace}"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${local.prefix}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "onecall" {
  filename      = "dist/bundle.zip"
  function_name = "${local.prefix}-onecall"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "app.handler"
  runtime       = "nodejs14.x"
}
