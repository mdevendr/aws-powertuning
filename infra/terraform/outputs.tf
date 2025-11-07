output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "power_tuner_arn" {
  value  = data.aws_sfn_state_machine.power_tuner.arn
}

output "ask_approval" {
  value = var.ask_approval
}

output "power_tuner_region" {
  value = var.power_tuner_region
}

output "reports_bucket_name" {
  value = aws_s3_bucket.tuning_reports.bucket
}
