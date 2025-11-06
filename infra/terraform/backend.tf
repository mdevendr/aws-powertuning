terraform {
  backend "s3" {
    bucket         = "serverless-power-tuning-tfstate"
    key            = "state/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "serverless-power-tuning-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region # eu-west-2
}

provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}
