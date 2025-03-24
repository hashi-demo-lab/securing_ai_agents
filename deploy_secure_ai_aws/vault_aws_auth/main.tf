// Enable AWS auth method
resource "vault_auth_backend" "aws" {
  type        = "aws"
  path        = "aws"
  description = "AWS authentication method for Lambda extension"
}

// Configure AWS client with default options
resource "vault_aws_auth_backend_client" "aws_client" {
  backend = vault_auth_backend.aws.path
  // Using default options as requested
}

// Create a policy for Lambda access
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
