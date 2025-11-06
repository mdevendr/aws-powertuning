terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

########################################
# DynamoDB Table
########################################
resource "aws_dynamodb_table" "table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

########################################
# IAM Role for Lambda Execution
########################################
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "${var.project}-lambda-exec-policy"
  description = "Least privilege access to DynamoDB + CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DynamoDBAccess",
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
      },
      {
        Sid    = "CloudWatchLogs",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

########################################
# Lambda Function
########################################
resource "aws_lambda_function" "api" {
  function_name = "${var.project}-function"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.11"
  handler       = "app.lambda_handler"
  filename      = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.table.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_exec_role_attach]
}

########################################
# API Gateway - REST API + Proxy Integrations
########################################
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.project}-api"
}

# /items
resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "items"
}

# ANY /items
resource "aws_api_gateway_method" "items_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "items" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items.id
  http_method             = aws_api_gateway_method.items_any.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.api.invoke_arn
}

# /items/{id}
resource "aws_api_gateway_resource" "item_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.items.id
  path_part   = "{id}"
}

# ANY /items/{id}
resource "aws_api_gateway_method" "item_id_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.item_id.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "item_id" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.item_id.id
  http_method             = aws_api_gateway_method.item_id_any.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.api.invoke_arn
}

########################################
# Permissions
########################################
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

########################################
# Deployment + Stage
########################################
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # ensure a new deployment when methods/integrations change
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

########################################
# Power Tuner via SAR (optional) + Resolve ARN
########################################

# Deploy Power Tuner with SAR if enabled and no external ARN passed
resource "aws_serverlessapplication_repository_cloudformation_stack" "power_tuner" {
  count            = var.enable_power_tuner_deploy && var.power_tuner_arn == "" ? 1 : 0
  name             = "${var.project}-power-tuner"
  # The SAR app is published in us-east-1; you can deploy into your current region
  application_id   = "arn:aws:serverlessrepo:us-east-1:451282441545:applications/aws-lambda-power-tuning"
  semantic_version = "4.7.0"

  # minimal parameters; the state machine doesn't need your function wired here
  # we’ll pass the Lambda ARN in the Step Functions execution input
  parameters = {}
}

# resolved ARN preference: SAR output if created, else variable
locals {
  resolved_power_tuner_arn = (
    var.enable_power_tuner_deploy && var.power_tuner_arn == "" && length(aws_serverlessapplication_repository_cloudformation_stack.power_tuner) > 0
  )
  ? aws_serverlessapplication_repository_cloudformation_stack.power_tuner[0].outputs["StateMachineArn"]
  : var.power_tuner_arn
}

# (Optional) permission to allow the power tuner state machine to invoke this Lambda
resource "aws_lambda_permission" "allow_stepfn" {
  count         = local.resolved_power_tuner_arn != "" ? 1 : 0
  statement_id  = "AllowExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "states.amazonaws.com"
  source_arn    = local.resolved_power_tuner_arn
}

########################################
# Outputs
########################################

output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "power_tuner_arn" {
  value = local.resolved_power_tuner_arn
}

# For visibility in CI
output "memory_update_mode" {
  value = var.memory_update_mode
}
