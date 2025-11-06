variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "project" {
  type    = string
  default = "serverless-power-tuning"
}

variable "table_name" {
  type    = string
  default = "LambdaPowerTuningTable"
}

variable "lambda_zip_path" {
  type    = string
  default = "../../lambda/package.zip"
}

variable "power_tuner_arn" {
  type    = string
  default = "arn:aws:states:eu-west-2:211125489043:stateMachine:aws-lambda-power-tuning"
}
