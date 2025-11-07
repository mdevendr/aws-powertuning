###############################################################################
# AWS Lambda Power Tuning (Serverless Application Repository)
###############################################################################

# Deploy AWS Lambda Power Tuner from Serverless Application Repository (SAR)
resource "aws_serverlessapplicationrepository_cloudformation_stack" "power_tuner" {
  name           = "${var.project}-power-tuner"
  application_id = var.power_tuner_application_id

  parameters = {
    # the parameters are passed at execution time as json;
    # https://github.com/alexcasalboni/aws-lambda-power-tuning/blob/1a54f2085db0a3aecac8b8d19f10ffecf80964db/README-EXECUTE.md
  }

  capabilities = ["CAPABILITY_IAM"]
}


