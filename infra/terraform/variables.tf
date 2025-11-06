
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project" {
  description = "Project prefix"
  type        = string
  default     = "serverless-power-tuning"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "lambda-power-tuning-tests"
}

variable "lambda_zip_path" {
  description = "Path to the packaged lambda zip"
  type        = string
  default     = "../../lambda/package.zip"
}


variable "deploy_power_tuner" {
  description = "Deploy the aws-lambda-power-tuning SAR app"
  type        = bool
  default     = true
}

variable "power_values" {
  description = "Memory sizes to test"
  type        = list(number)
  default     = [128, 256, 512, 1024]
}
