variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "serverless-power-tuning"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "LambdaPowerTuningTable"
}

variable "lambda_zip_path" {
  description = "Path to packaged Lambda ZIP"
  type        = string
  default     = "lambda.zip"
}


# Toggle to auto-deploy Power Tuner via SAR (recommended)
variable "enable_power_tuner_deploy" {
  description = "Deploy AWS Lambda Power Tuner via SAR"
  type        = bool
  default     = true
}

# Controls whether memory updates are auto-applied or require approval in CI
variable "ask_approval" {
  description = "auto = update memory automatically, manual = require approval gate in CI"
  type        = bool
  default     = true
}

variable "lambdaPowerValues" {
  type  = string
  default = "128,256,512,1024,1536,2048"
}

variable "power_tuner_application_id" {
  type = string
  default = "arn:aws:serverlessrepo:us-east-1:451282441545:applications/aws-lambda-power-tuning"
}

variable "semantic_version" {
  type = string
  default = "4.4.0"
}

variable "account_id" {
  type = string
  default = ""
}

variable "github_oidc_role" {
  type = string
  default = "github-oidc-deploy-role"
}