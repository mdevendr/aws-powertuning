#!/bin/bash
set -e

# -----------------------------
# CONFIGURATION - EDIT THESE
# -----------------------------
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_ORG="mdevendr"
GITHUB_REPO="aws-powertuning"
ROLE_NAME="github-oidc-deploy-role"
REGION="eu-west-2"
SAR_APP_ARN="arn:aws:serverlessrepo:us-west-2:451282441545:applications/aws-lambda-power-tuning"
# -----------------------------

OIDC_PROVIDER="token.actions.githubusercontent.com"

echo "🔍 Checking OIDC Provider..."
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER \
  >/dev/null 2>&1 || {

  echo "⚙️ Creating OIDC Provider..."
  aws iam create-open-id-connect-provider \
    --url "https://token.actions.githubusercontent.com" \
    --client-id-list "sts.amazonaws.com" \
    --thumbprint-list "6938ef5d6138fbb87b3b0b1dd5d2efb0d282cc4a"
}

echo "📝 Creating trust policy file..."
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:$GITHUB_ORG/$GITHUB_REPO:*",
            "repo:$GITHUB_ORG/*:*"
          ]
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

echo "🔧 Creating / Updating IAM Role: $ROLE_NAME..."
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json \
  >/dev/null 2>&1 || aws iam update-assume-role-policy \
  --role-name $ROLE_NAME \
  --policy-document file://trust-policy.json

echo "🔗 Attaching IAM Policies..."
cat > deployment-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformAndLambdaDeploy",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole",
        "lambda:*",
        "logs:*",
        "dynamodb:*",
        "apigateway:*",
        "s3:*",
        "cloudformation:*",
        "states:*",
        "serverlessrepo:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name $ROLE_NAME \
  --policy-name deploy-permissions \
  --policy-document file://deployment-policy.json

echo "🔐 Adding SAR Deployment Policy (App-level permission)..."
aws serverlessrepo put-application-policy \
  --application-id "$SAR_APP_ARN" \
  --statements "[
    {
      \"StatementId\": \"AllowDeployFrom$ACCOUNT_ID\",
      \"Actions\": [\"serverlessrepo:CreateCloudFormationChangeSet\"],
      \"Principals\": [\"$ACCOUNT_ID\"]
    }
  ]"

ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

echo ""
echo "✅ DONE — Your GitHub Actions Role is Ready!"
echo ""
echo "👉 Copy this into your GitHub Actions workflows:"
echo ""
echo "      role-to-assume: $ROLE_ARN"
echo "      aws-region: $REGION"
echo ""
echo "🎉 Setup Complete"
