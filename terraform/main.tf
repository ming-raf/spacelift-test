terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example-api"
  description = "Example API Gateway"
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_inline.zip"
  source {
    content  = <<EOF
import json

def lambda_handler(event, context):
    print("Hello, World!")
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
EOF
    filename = "index.py"
  }
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda"
  runtime      = "python3.8"
  handler      = "lambda_function.lambda_handler"
  role = aws_iam_role.example_lambda_role.arn
  filename         = "${data.archive_file.lambda_zip_inline.output_path}"
  source_code_hash = "${data.archive_file.lambda_zip_inline.output_base64sha256}"
}

resource "aws_iam_role" "example_lambda_role" {
  name = "example-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "example_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "example_method_response" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.example_resource.id
  http_method = aws_api_gateway_method.example_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "example_integration_response" {
  rest_api_id         = aws_api_gateway_rest_api.example_api.id
  resource_id         = aws_api_gateway_resource.example_resource.id
  http_method         = aws_api_gateway_method.example_method.http_method
  status_code         = aws_api_gateway_method_response.example_method_response.status_code
  response_templates  = {
    "application/json" = ""
  }
}
