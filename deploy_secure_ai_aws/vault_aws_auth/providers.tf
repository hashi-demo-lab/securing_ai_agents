terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}
# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "vault" {
  address = var.vault_address
  namespace = var.vault_namespace
}