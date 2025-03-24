# Vault AWS Auth Module for Lambda

```zsh
export VAULT_TOKE="hvs...  "
terraform init
terraform plan
terraform apply
```

This Terraform module configures HashiCorp Vault with AWS authentication for Lambda functions using the Vault Lambda extension.

## Features

- Enables the AWS auth method in Vault
- Configures AWS client with default options
- Creates a Vault role prefixed with the AWS environment name
- Sets up IAM roles and policies required for Lambda to authenticate with Vault
- Configures an example Lambda function with the Vault Lambda extension

## Usage

### Basic Usage

```hcl
module "vault_aws_auth" {
  source = "./deploy_secure_ai_aws/vault_aws_auth"

  aws_region         = "us-west-2"
  aws_environment_name = "prod"
  vault_address      = "https://vault.example.com:8200"
}
```

### Custom Lambda Function Configuration

```hcl
module "vault_aws_auth" {
  source = "./deploy_secure_ai_aws/vault_aws_auth"

  aws_region         = "us-west-2"
  aws_environment_name = "prod"
  
  # Lambda configuration
  lambda_function_name = "my-secure-function"
  lambda_handler       = "app.handler"
  lambda_runtime       = "python3.9"
  lambda_zip_path      = "./lambda_deployment_package.zip"
  
  # Vault configuration
  vault_address        = "https://vault.example.com:8200"
  vault_secret_path    = "secret/data/myapp/config"
  
  # Token configuration
  token_ttl            = 600  # 10 minutes
  token_max_ttl        = 1800  # 30 minutes
}
```

### Using an Existing Lambda Role

```hcl
module "vault_aws_auth" {
  source = "./deploy_secure_ai_aws/vault_aws_auth"

  aws_region         = "us-west-2"
  aws_environment_name = "prod"
  lambda_role_arn    = "arn:aws:iam::123456789012:role/existing-lambda-role"
  
  # Other Lambda configuration
  lambda_function_name = "my-secure-function"
  lambda_handler       = "app.handler"
  lambda_runtime       = "python3.9"
}
```

## Required Variables

- None (all variables have defaults)

## Optional Variables

| Name | Description | Default |
|------|-------------|---------|
| aws_region | AWS Region to be used | ap-southeast-1 |
| aws_environment_name | AWS Environment name (e.g., dev, prod, staging) | dev |
| lambda_role_arn | ARN of an existing IAM role for Lambda | null |
| lambda_function_name | Name of the Lambda function | vault-auth-lambda |
| lambda_handler | Handler function for Lambda | index.handler |
| lambda_runtime | Runtime for the Lambda function | nodejs18.x |
| lambda_zip_path | Path to the Lambda deployment package | lambda_function_payload.zip |
| lambda_vault_extension_layer_arn | ARN of the Vault Lambda extension layer | null (auto-detected) |
| vault_address | URL of your Vault server | https://vault.example.com:8200 |
| vault_secret_path | Path to secrets in Vault | secret/data/lambda/config |
| token_ttl | Default TTL for tokens issued to Lambda (in seconds) | 960 (16 minutes) |
| token_max_ttl | Maximum TTL for tokens issued to Lambda (in seconds) | 1200 (20 minutes) |

## Outputs

| Name | Description |
|------|-------------|
| lambda_role_arn | ARN of the IAM role for Lambda with Vault authentication capabilities |
| lambda_function_name | Name of the Lambda function that uses Vault authentication |
| vault_auth_path | Path where the AWS auth method is enabled in Vault |
| vault_role_name | Name of the role created in Vault for Lambda authentication |
| vault_policy_name | Name of the Vault policy attached to the Lambda role | 