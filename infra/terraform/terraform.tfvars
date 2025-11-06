
aws_region     = "eu-west-2"
project        = "serverless-power-tuning"
table_name     = "items"
lambda_zip_path= "../../lambda/package.zip"

deploy_power_tuner = true
power_values       = [128,256,512,1024]
