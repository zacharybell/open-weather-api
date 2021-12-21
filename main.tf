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
  filename         = "dist/bundle.zip"
  function_name    = "${local.prefix}-onecall"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "app.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("dist/bundle.zip")

  environment {
    variables = {
      OPEN_WEATHER_API_KEY = "${var.OPEN_WEATHER_API_KEY}"
    }
  }
}

resource "aws_apigatewayv2_api" "main" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.main.name}"

  retention_in_days = 5
}

resource "aws_apigatewayv2_stage" "v1" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "v1"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "onecall" {
  api_id = aws_apigatewayv2_api.main.id

  integration_uri    = aws_lambda_function.onecall.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "onecall" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "GET /weather"
  target    = "integrations/${aws_apigatewayv2_integration.onecall.id}"
}

resource "aws_lambda_permission" "onecall" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.onecall.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
