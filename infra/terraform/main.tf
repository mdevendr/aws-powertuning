
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DynamoDB table
resource "aws_dynamodb_table" "items" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAM role for Lambda
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem", "dynamodb:Scan"]
    resources = [aws_dynamodb_table.items.arn]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.project}-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Package Lambda (expects ../lambda/package.zip created by CI/job or local script)
resource "aws_lambda_function" "api" {
  function_name = "${var.project}-function"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.11"
  handler       = "app.lambda_handler"
  filename      = var.lambda_zip_path

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_attach]
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project}-api"
  description = "REST API for ${var.project}"
}

resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_resource" "item_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.items.id
  path_part   = "{id}"
}

# Methods
resource "aws_api_gateway_method" "items_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "item_id_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.item_id.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Integrations with Lambda (proxy)
resource "aws_api_gateway_integration" "items" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items.id
  http_method             = aws_api_gateway_method.items_any.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_api_gateway_integration" "item_id" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.item_id.id
  http_method             = aws_api_gateway_method.item_id_any.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.api.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Deployment + Stage
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeploy = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }
  depends_on = [
    aws_api_gateway_integration.items,
    aws_api_gateway_integration.item_id
  ]
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deploy.id
  stage_name    = "prod"
}

output "api_url" {
  value = aws_api_gateway_rest_api.api.execution_arn
}

output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "lambda_name" {
  value = aws_lambda_function.api.function_name
}

output "table_name" {
  value = aws_dynamodb_table.items.name
}


# ---- Optional: Deploy AWS Lambda Power Tuning (SAR) ----
# Creates a CloudFormation stack for the open-source app and outputs the StateMachineArn.
resource "aws_serverlessapplicationrepository_cloudformation_stack" "power_tuner" {
  count          = var.deploy_power_tuner ? 1 : 0
  name           = "${var.project}-power-tuner"
  application_id = "arn:aws:serverlessrepo:us-east-1:451282441545:applications/aws-lambda-power-tuning"
  capabilities   = ["CAPABILITY_IAM"]
  parameters     = {}
}

# Expose the State Machine ARN (either from SAR or left empty when not deployed)
output "power_tuner_arn" {
  value = var.deploy_power_tuner ? aws_serverlessapplicationrepository_cloudformation_stack.power_tuner[0].outputs.StateMachineArn : ""
}
