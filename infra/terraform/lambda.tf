########################################
# Lambda Function
########################################
resource "aws_lambda_function" "api" {
  function_name = "${var.project}-function"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.11"
  handler       = "app.lambda_handler"
  filename      = var.lambda_zip_path

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.table.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_exec_role_attach]
}

########################################
# Permissions
########################################
resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}


resource "aws_lambda_permission" "allow_stepfn" {
  statement_id  = "AllowExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_serverlessapplicationrepository_cloudformation_stack.power_tuner.outputs["StateMachineArn"]
}