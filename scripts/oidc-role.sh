#!/bin/bash
set -e

# ----- CHANGE THESE -----
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_ORG="mdevendr"
GITHUB_REPO="aws-serverless-design-patterns"
ROLE_NAME="github-oidc-deploy-role"
POLICY_FILE="policy.json"   # Must be in the same folder
# -------------------------

OIDC_PROVIDER="token.actions.githubusercontent.com"

echo "✅ Checking if OIDC provider exists..."
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER \
  >/dev/null 2>&1 || {

  echo "🔧 Creating OIDC Provider..."
  aws iam create-open-id-connect-provider \
    --url "https://token.actions.githubusercontent.com" \
    --client-id-list "sts.amazonaws.com" \
    --thumbprint-list "6938ef5d6138fbb87b3b0b1dd5d2efb0d282cc4a"
}

echo "✅ Creating trust policy..."
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:mdevendr/aws-powertuning:ref:refs/heads/main"
        }
      }
    }
  ]
}
EOF

echo "✅ Creating IAM role: $ROLE_NAME ..."
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json \
  >/dev/null 2>&1 || echo "ℹ️ Role already exists, continuing."

echo "✅ Attaching custom deployment policy..."
aws iam put-role-policy \
  --role-name $ROLE_NAME \
  --policy-name ${ROLE_NAME}-policy \
  --policy-document file://$POLICY_FILE

ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

aws iam update-open-id-connect-provider-thumbprint \
  --open-id-connect-provider-arn arn:aws:iam::211125489043:oidc-provider/token.actions.githubusercontent.com \
  --thumbprint-list 6938ef5d6138fbb87b3b0b1dd5d2efb0d282cc4a


echo ""
echo "🎉 Role is ready!"
echo "👉 Use this in your GitHub Actions workflow:"
echo ""
echo "      role-to-assume: $ROLE_ARN"
echo ""
