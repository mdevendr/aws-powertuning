terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "serverless-power-tuning-tfstate"
    key            = "state/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "serverless-power-tuning-tf-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
