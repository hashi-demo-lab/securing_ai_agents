variable "kube_config_path" {
  type        = string
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config" # Default path on Mac
}

variable "kube_config_context" {
  type        = string
  description = "Kubeconfig context to use"
  default     = "docker-desktop"
}

variable "vault_license" {
  type        = string
  description = "Vault License"
}

variable "aws_credentials" {
  description = "AWS Credentials Map (Access Key, Secret Key, Session Token)"
  type        = map(string)
  default     = {}
}

variable "primary_vault_common_name" {
  type        = string
  description = "Common name for Vault certificate"
  default     = "vault.hashibank.com"
}

variable "primary_vault_dns_names" {
  type        = list(string)
  description = "DNS names for Vault certificate"
  default = [
    "vault.hashibank.com",
    "vault.primary-vault.svc.cluster.local",
    "vault-active.primary-vault.svc.cluster.local",
    "vault-standby.primary-vault.svc.cluster.local",
    "vault-internal.primary-vault.svc.cluster.local",
    "vault-0.primary-vault.svc.cluster.local",
    "vault-1.primary-vault.svc.cluster.local",
    "vault-2.primary-vault.svc.cluster.local",
    "vault-3.primary-vault.svc.cluster.local",
    "vault-4.primary-vault.svc.cluster.local",
    "vault-0.vault-internal.primary-vault.svc.cluster.local",
    "vault-1.vault-internal.primary-vault.svc.cluster.local",
    "vault-2.vault-internal.primary-vault.svc.cluster.local",
    "vault-3.vault-internal.primary-vault.svc.cluster.local",
    "vault-4.vault-internal.primary-vault.svc.cluster.local"
  ]
}

variable "auto_unseal_vault_common_name" {
  type        = string
  description = "Common name for Auto Unseal Vault certificate"
  default     = "auto-unseal-vault.hashibank.com"
}

variable "auto_unseal_vault_dns_names" {
  type        = list(string)
  description = "DNS names for Auto Unseal Vault certificate"
  default = [
    "auto-unseal-vault.hashibank.com",
    "auto-unseal-vault-0.auto-unseal-vault-internal.auto-unseal-vault.svc.cluster.local",
    "auto-unseal-vault-0.auto-unseal-vault.svc.cluster.local"
  ]
}

variable "organization" {
  type        = string
  description = "Organization name for both Vault and LDAP certificates"
  default     = "HashiBank"
}

variable "prometheus_helm_version" {
  type        = string
  description = "Prometheus Helm Release Version"
  default     = "~> 24"
}

# variable "prometheus_targets" {
#   type    = list(string)
#   default = ["vault-active.primary-vault.svc.cluster.local:8200"]
# }

variable "grafana_helm_version" {
  type        = string
  description = "Grafana Helm Release Version"
  default     = "~> 7"
}

variable "loki_helm_version" {
  type        = string
  description = "Loki Helm Release Version"
  default     = "~> 2"
}

variable "promtail_helm_version" {
  type        = string
  description = "Promtail Helm Release Version"
  default     = "~> 0"
}

variable "ldap_dns_names" {
  type        = list(string)
  description = "DNS names for LDAP certificate"
  default = [
    "ldap.hashibank.com",
    "phpldapadmin.hashibank.com",
    "openldap.ldap.svc.cluster.local",
    "openldap-0.ldap.svc.cluster.local",
    "openldap-phpldapadmin.ldap.svc.cluster.local"
  ]
}

variable "ldap_common_name" {
  type        = string
  description = "Common name for LDAP certificate"
  default     = "ldap.hashibank.com"
}

variable "gitlab_runner_token" {
  description = "GitLab runner registration token"
  type        = string
  sensitive   = true # To keep the token secure
  default     = null
}

# variable "github_organization" {
#   type        = string
#   description = "GitHub Organization"
# }

# variable "oidc_client_id" {
#   type        = string
#   description = "value of the client_id"
# }

# variable "oidc_client_secret" {
#   type        = string
#   description = "value of the client_secret"
# }