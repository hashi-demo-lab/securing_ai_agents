variable "host" {
  description = "OpenShift cluster API URL"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "OpenShift cluster CA certificate (base64 encoded)"
  type        = string
}

variable "client_key" {
  description = "Client key for OpenShift authentication (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "client_certificate" {
  description = "Client certificate for OpenShift authentication (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "enable_vso" {
  description = "Enable or disable Vault Secrets Operator installation"
  type        = bool
  default     = false
}

variable "create_vso_namespace" {
  description = "Create or use existing namespace for Vault Secrets Operator installation"
  type        = bool
  default     = false
}

variable "vso_namespace" {
  description = "Namespace for Vault Secrets Operator installation"
  type        = string
  default     = "vault"
}

variable "enable_pipelines" {
  description = "Enable or disable OpenShift Pipelines Operator installation"
  type        = bool
  default     = true
}

variable "enable_gitops" {
  description = "Enable or disable OpenShift GitOps Operator installation"
  type        = bool
  default     = true
}

variable "create_gitops_namespace" {
  description = "Create or use existing namespace for OpenShift GitOps Operator installation"
  type        = bool
  default     = true
}

variable "gitops_namespace" {
  description = "Namespace for OpenShift GitOps Operator installation"
  type        = string
  default     = "openshift-gitops-operator"
}
