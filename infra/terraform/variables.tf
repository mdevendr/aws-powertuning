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

# If you already have a Power Tuner, you can pass its ARN here.
# If left empty and enable_power_tuner_deploy=true, Terraform deploys Power Tuner via SAR and uses that ARN.
variable "power_tuner_arn" {
  description = "Existing AWS Lambda Power Tuner State Machine ARN (optional)"
  type        = string
  default     = ""
}

# Toggle to auto-deploy Power Tuner via SAR (recommended)
variable "enable_power_tuner_deploy" {
  description = "Deploy AWS Lambda Power Tuner via SAR"
  type        = bool
  default     = true
}

# Controls whether memory updates are auto-applied or require approval in CI
variable "memory_update_mode" {
  description = "auto = update memory automatically, manual = require approval gate in CI"
  type        = string
  default     = "manual"
}
