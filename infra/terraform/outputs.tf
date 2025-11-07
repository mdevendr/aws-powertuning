output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "power_tuner_arn" {
  value = local.power_tuner_arn
}

output "ask_approval" {
  value = var.ask_approval
}

output "power_tuner_state_machine_arn" {
  value = data.aws_sfn_state_machine.power_tuner.arn
  description = "State Machine ARN for AWS Lambda Power Tuning"
}

output "power_tuner_region" {
  value = local.power_tuner_region
}