# Serverless Power Tuning Pattern — vFINAL (Production-Safe)

This repo reuses existing AWS resources to avoid IAM/DynamoDB/SAR conflicts:

- **DynamoDB table:** `LambdaPowerTuningTable` (created by Terraform in this repo)
- **Lambda Execution Role:** `arn:aws:iam::211125489043:role/serverless-power-tuning-lambda-role`
- **AWS Lambda Power Tuning (Step Functions):** `arn:aws:states:eu-west-2:211125489043:stateMachine:aws-lambda-power-tuning`

It deploys:
- A **Python 3.11 Lambda** (handler: `app.lambda_handler`)
- A **REST API Gateway** (`/items`, `/items/{id}`) proxying to Lambda
- **No IAM creation** in Terraform (we reuse the existing role)
- Remote Terraform state via **S3 + DynamoDB**

## Prereqs
- S3 bucket: `serverless-power-tuning-tfstate`
- DynamoDB lock table: `serverless-power-tuning-tf-lock` (PAY_PER_REQUEST is fine)
- IAM Role for Lambda execution: `arn:aws:iam::211125489043:role/serverless-power-tuning-lambda-role`
  - Must allow CloudWatch Logs and DynamoDB access to `LambdaPowerTuningTable`
- Step Functions state machine for Power Tuning: `arn:aws:states:eu-west-2:211125489043:stateMachine:aws-lambda-power-tuning`

## Local deploy (optional)
```bash
cd infra/terraform
terraform init -migrate-state
# build lambda package
( cd ../../lambda && chmod +x package.sh && ./package.sh )
terraform apply -auto-approve
```

## GitHub Actions
- **PR → main**: package + plan + tests (no deploy)
- **Push to main**: deploy (only by @mdevendr), run power tuning, update Lambda memory, run Newman tests, upload HTML report.

## Variables
- Change `infra/terraform/terraform.tfvars` if you need to point to a different role/table/tuner ARN.
