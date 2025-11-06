
# Serverless Power Tuning Pattern (API Gateway → Lambda → DynamoDB)

This repo deploys a simple REST API backed by Lambda and DynamoDB and includes a GitHub Actions workflow that
runs **AWS Lambda Power Tuning** (Step Functions), parses the recommended memory size, updates the Lambda configuration,
and (optionally) runs Postman load tests via Newman.

## What you get
- Terraform IaC to create:
  - DynamoDB table (`items`)
  - Python Lambda (`app.lambda_handler`)
  - REST API Gateway with `/items` (GET/POST) and `/items/{id}` (GET/DELETE)
- GitHub Actions workflow:
  - Builds and deploys Lambda (zip upload)
  - Invokes the **aws-lambda-power-tuning** Step Functions state machine
  - Picks the recommended memory size (balanced by default)
  - Updates the Lambda memory
  - (Optional) Runs Newman with your Postman collection

## Prereqs
- AWS account and credentials (OIDC or long‑lived secrets)
- Terraform >= 1.6
- An existing **AWS Lambda Power Tuning** state machine (from SAR) **or** let Terraform deploy it via the official template (toggle in variables).
- GitHub OIDC role or AWS credentials set as repository secrets.

## Quick start
1. Clone and edit `infra/terraform/terraform.tfvars` with your values.
2. `cd infra/terraform && terraform init && terraform apply -auto-approve`
3. Push to GitHub. The workflow `.github/workflows/power-tune.yml` can also be triggered using **Run workflow**.
4. Check the Step Functions execution and logs. The workflow will update the function memory automatically.


### Power Tuner deployment
By default, Terraform **deploys** the official *aws-lambda-power-tuning* SAR app and exposes its State Machine ARN as `power_tuner_arn` output.  
Set `deploy_power_tuner = false` in `terraform.tfvars` if you want to use an existing state machine and pass its ARN via a GitHub secret instead.
