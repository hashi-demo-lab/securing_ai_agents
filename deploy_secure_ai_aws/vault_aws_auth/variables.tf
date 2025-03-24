variable "aws_region" {
  description = "AWS Region to be used"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_environment_name" {
  description = "AWS Environment name (e.g., dev, prod, staging) used as prefix for Vault roles"
  type        = string
  default     = "ai-demo"
}

variable "lambda_role_arn" {
  description = "ARN of an existing IAM role used by Lambda functions (if you don't want to create a new one)"
  type        = string
  default     = null
}


variable "vault_address" {
  description = "URL of your Vault server"
  type        = string
}

variable "vault_namespace" {
  description = "Namespace of your Vault server (if you are using one)"
  type        = string
  default     = "admin" # HCP Vault uses "admin" as the default namespace
}

variable "vault_secret_path" {
  description = "Path to secrets in Vault that Lambda needs to access"
  type        = string
  default     = "secret/data/lambda/config"
}

variable "token_ttl" {
  description = "Default TTL for tokens issued to Lambda (in seconds)"
  type        = number
  default     = 960 # 16 minutes

  validation {
    condition     = var.token_ttl > 0 && var.token_ttl <= 3600
    error_message = "Token TTL must be between 1 and 3600 seconds (1 hour)."
  }
}

variable "token_max_ttl" {
  description = "Maximum TTL for tokens issued to Lambda (in seconds)"
  type        = number
  default     = 1200 # 20 minutes

  validation {
    condition     = var.token_max_ttl > 0 && var.token_max_ttl <= 86400
    error_message = "Token max TTL must be between 1 and 86400 seconds (24 hours)."
  }
}

variable "assume_role" {
  description = "Whether to create an policy for assume role for Lambda to assume"
  type        = bool
  default     = true
}