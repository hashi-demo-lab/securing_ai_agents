// Output the Lambda role ARN to be used in the vault configuration
output "lambda_role_arn" {
  value       = aws_iam_role.lambda.arn
  description = "ARN of the IAM role for Lambda with Vault authentication capabilities"
}

output "lambda_role_id" {
  value       = aws_iam_role.lambda.id
  description = "ID of the IAM role for Lambda with Vault authentication capabilities"
}

output "vault_auth_path" {
  value       = vault_auth_backend.aws.path
  description = "Path where the AWS auth method is enabled in Vault"
}

output "vault_role_name" {
  value       = vault_aws_auth_backend_role.lambda_role.role
  description = "Name of the role created in Vault for Lambda authentication"
}

output "vault_policy_name" {
  value       = vault_policy.lambda_policy.name
  description = "Name of the Vault policy attached to the Lambda role"
}

output "rds_address" {
  value       = aws_db_instance.main.address
  description = "RDS address"
}

output "vault_secret_path_db" {
  value       = "${vault_mount.database.path}/creds/${vault_database_secret_backend_role.lambda_function.name}"
  description = "Vault Secret path to the DB creds"
}

# output "vault_sample_secret_mount_path" {
#   value       = vault_mount.kv_secrets.path
#   description = "Name of the Path to the Vault sample secret"
# }

# output "vault_sample_secret_name" {
#   value       = vault_kv_secret_v2.lambda_secret.name
#   description = "Name of the Vault sample secret"
# }