data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

data "terraform_remote_state" "vault_aws_auth" {
  backend = "local"

  config = {
    path = "../vault_aws_auth/terraform.tfstate"
  }
}