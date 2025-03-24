// Enable AWS auth method
resource "vault_auth_backend" "aws" {
  type        = "aws"
  path        = "aws"
  description = "AWS authentication method for Lambda extension"
}



### THIS IS NOT RECOMMENDED FOR PRODUCTION USE ###
## workaround for Doormat ##
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

data "aws_iam_policy" "security_compute_access" {
  name = "SecurityComputeAccess"
}

resource "aws_iam_user_policy_attachment" "vault_mount_user" {
  user       = aws_iam_user.vault_mount_user.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${var.aws_environment_name}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}

resource "vault_aws_auth_backend_client" "client" {
  backend    = vault_auth_backend.aws.path
  access_key = aws_iam_access_key.vault_mount_user.id
  secret_key = aws_iam_access_key.vault_mount_user.secret
}

### THIS IS NOT RECOMMENDED FOR PRODUCTION USE ###
## workaround for Doormat ##

resource "vault_aws_auth_backend_config_identity" "identity_config" {
  backend   = vault_auth_backend.aws.path
  iam_alias = "role_id"
  iam_metadata = [
    "account_id",
    "auth_type",
    "canonical_arn",
    "client_arn",
    "client_user_id"]
}



// Create a Vault policy for Lambda access
resource "vault_policy" "lambda_policy" {
  name = "lambda-policy"

  policy = file("${path.module}/policies/lambda_policy.hcl")
}

// Cross-variable validation
locals {
  // Token TTL validation - max_ttl must be greater than ttl
  valid_ttl_values = var.token_max_ttl > var.token_ttl
}

// Create a vault role prefixed with AWS environment name
resource "vault_aws_auth_backend_role" "lambda_role" {
  backend                  = vault_auth_backend.aws.path
  role                     = "${var.aws_environment_name}-lambda-role"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.lambda_vault_role.arn]
  token_ttl                = var.token_ttl
  token_max_ttl            = var.token_max_ttl
  token_policies           = [vault_policy.lambda_policy.name]

  lifecycle {
    precondition {
      condition     = local.valid_ttl_values
      error_message = "The token_max_ttl (${var.token_max_ttl}) must be greater than token_ttl (${var.token_ttl})."
    }
  }
}
