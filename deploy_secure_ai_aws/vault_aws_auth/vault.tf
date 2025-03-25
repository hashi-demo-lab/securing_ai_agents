// Enable AWS auth method
resource "vault_auth_backend" "aws" {
  type        = "aws"
  path        = "aws"
  description = "AWS authentication method for Lambda extension"
}

## this is not recommended for production use - required due to cross account and doormat
resource "vault_aws_auth_backend_client" "client" {
  backend    = vault_auth_backend.aws.path
  access_key = aws_iam_access_key.vault_mount_user.id
  secret_key = aws_iam_access_key.vault_mount_user.secret
  # sts_endpoint = "https://sts.${var.aws_region}.amazonaws.com"
  # sts_region = var.aws_region
}

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


resource "time_sleep" "wait_for_iam" {
 depends_on = [ aws_iam_role.extra_role ]
 create_duration  = "10s"
 destroy_duration = "10s"

 # This ensures that the sleep is re-created when the role assignments change.
 triggers = {
   role_assignments = jsonencode(aws_iam_role.extra_role)
 }
}


// Create a vault role prefixed with AWS environment name
resource "vault_aws_auth_backend_role" "lambda_role" {
  depends_on = [ time_sleep.wait_for_iam ]
  backend                  = vault_auth_backend.aws.path
  role                     = "${var.aws_environment_name}-lambda-role"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.lambda.arn, aws_iam_role.extra_role[0].arn]
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
