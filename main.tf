terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "zacharybell-terraform-state"
    key            = "open-weather-api.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-2"
}