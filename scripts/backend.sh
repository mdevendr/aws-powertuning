
aws s3api create-bucket \
  --bucket serverless-power-tuning-tfstate \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2

aws dynamodb create-table \
  --table-name serverless-power-tuning-tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-2
