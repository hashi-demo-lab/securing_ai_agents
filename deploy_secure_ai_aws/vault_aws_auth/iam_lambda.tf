// Create IAM role for Lambda with Vault authentication
resource "aws_iam_role" "lambda_vault_role" {
  name = "${var.aws_environment_name}-lambda-vault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  #managed_policy_arns = [data.aws_iam_policy.security_compute_access.arn]
  managed_policy_arns = [ data.aws_iam_policy.security_compute_access.arn ]

  tags = {
    Environment = var.aws_environment_name
    Purpose     = "Vault Authentication"
  }
}

// Policy allowing Lambda to generate temporary credentials for Vault auth
resource "aws_iam_policy" "lambda_vault_auth" {
  name        = "${var.aws_environment_name}-lambda-vault-auth"
  description = "Policy allowing Lambda to authenticate with Vault using AWS auth method"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      }
    ]
  })
}

// Attach the Vault auth policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_vault_auth_attachment" {
  role       = aws_iam_role.lambda_vault_role.name
  policy_arn = aws_iam_policy.lambda_vault_auth.arn
}