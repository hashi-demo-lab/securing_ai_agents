variable "region" {
  description = "Region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "foundation_model" {
  description = "The foundation model to use for the Bedrock Agent"
  type        = string
  default     = "amazon.titan-text-premier-v1:0"
}

variable "vault_addr" {
  description = "The Vault Address"
  type        = string
}

variable "instana_agent_key" {
  default = "The IBM Instana Agent Key"
  type    = string
}