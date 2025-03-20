# -------------------------------
# Vault Deployment Configuration
# -------------------------------
variable "vault_namespace" {
  description = "Namespace for the Vault deployment in Kubernetes."
  type        = string
}

variable "vault_mode" {
  description = "Deployment mode for Vault. Possible values: 'primary' or 'auto_unseal'."
  type        = string
}

variable "vault_release_name" {
  description = "The Helm release name for the Vault deployment."
  type        = string
  default     = "vault"
}

variable "vault_version" {
  description = "Version of HashiCorp Vault to deploy."
  type        = string
  default     = "latest"
}

variable "vault_helm_version" {
  description = "Helm chart version for deploying Vault."
  type        = string
  default     = "~> 0"
}

# -------------------------------
# Vault High Availability (HA)
# -------------------------------
variable "vault_ha_enabled" {
  description = "Enable High Availability (HA) mode for Vault."
  type        = bool
  default     = true
}

variable "vault_replicas" {
  description = "Number of Vault replicas to deploy when HA mode is enabled."
  type        = number
  default     = 3
}

# -------------------------------
# Vault Initialization & Configuration
# -------------------------------
variable "vault_initialization_script" {
  description = "Contents of the Vault initialization script."
  type        = string
}

variable "auto_unseal_config_script" {
  description = "Optional script for configuring the transit secret engine for auto-unseal."
  type        = string
  default     = ""
}

variable "configure_seal" {
  description = "Enable auto-unseal using a transit seal configuration."
  type        = bool
  default     = false
}

variable "auto_unseal_addr" {
  description = "Address of the Vault instance handling auto-unseal, used by the primary Vault."
  type        = string
  default     = "auto-unseal-vault-0.auto-unseal-vault-internal.auto-unseal-vault.svc.cluster.local:8200"
}

variable "auto_unseal_key_name" {
  description = "Transit key name used for auto-unseal."
  type        = string
  default     = "autounseal"
}

# -------------------------------
# TLS Configuration
# -------------------------------
variable "vault_cert_pem" {
  description = "PEM-encoded Vault TLS certificate."
  type        = string
}

variable "vault_private_key_pem" {
  description = "PEM-encoded private key for the Vault TLS certificate."
  type        = string
}

variable "ca_cert_pem" {
  description = "PEM-encoded CA certificate used for Vault TLS."
  type        = string
}

variable "vault_dns_names" {
  description = "List of DNS names to include in the Vault TLS certificate."
  type        = list(string)
}

variable "vault_common_name" {
  description = "Common Name (CN) for the Vault TLS certificate."
  type        = string
}

variable "organization" {
  description = "Organization name to be included in TLS certificates."
  type        = string
}

# -------------------------------
# Licensing & Integrations
# -------------------------------
variable "vault_license" {
  description = "HashiCorp Vault Enterprise license key."
  type        = string
}

variable "vso_helm" {
  description = "Optional Helm values for deploying the Vault Secrets Operator."
  type        = string
  default     = null
}

variable "enable_service_registration" {
  description = "Enable Kubernetes service registration for Vault."
  type        = bool
  default     = true
}

# -------------------------------
# AWS Credentials (Optional)
# -------------------------------
variable "aws_credentials" {
  description = "Map containing AWS credentials (Access Key, Secret Key, and Session Token). Used if AWS integrations are enabled."
  type        = map(string)
  default     = {}
}
