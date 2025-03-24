// Output the Lambda role ARN to be used in the vault configuration
output "lambda_role_arn" {
  value       = aws_iam_role.lambda_vault_role.arn
  description = "ARN of the IAM role for Lambda with Vault authentication capabilities"
}

// Output the Vault AWS auth path
output "vault_auth_path" {
  value       = vault_auth_backend.aws.path
  description = "Path where the AWS auth method is enabled in Vault"
}

// Output the Vault role name
output "vault_role_name" {
  value       = vault_aws_auth_backend_role.lambda_role.role
  description = "Name of the role created in Vault for Lambda authentication"
}

// Output the Vault policy name 
output "vault_policy_name" {
  value       = vault_policy.lambda_policy.name
  description = "Name of the Vault policy attached to the Lambda role"
}
