terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~> 3.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.15"
    }
  }
  required_version = ">= 1.8"
}
# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}