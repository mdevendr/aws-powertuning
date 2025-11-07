###############################################################################
# AWS Lambda Power Tuning (Serverless Application Repository)
###############################################################################

resource "aws_serverlessapplicationrepository_cloudformation_stack" "power_tuner" {
  name           = var.aws_powertuning_name
  application_id = var.power_tuner_application_id
  semantic_version = var.semantic_version

  parameters = {
    lambdaResource     = ""
    powerValues        = var.lambdaPowerValues
    parallelInvocation = "true"
    executionMode      = "Standard"
  }

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
}


###############################################################################
# Output the Power Tuner ARN
###############################################################################

data "aws_sfn_state_machine" "power_tuner" {
  provider = aws.powertuner
  name     = var.aws_powertuning_name
  depends_on = [
    aws_cloudformation_stack.power_tuner
  ]
}


