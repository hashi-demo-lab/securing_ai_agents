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

variable "argocd_server_addr" {
  description = "ArgoCD server address"
  type        = string
}

variable "argocd_username" {
  description = "ArgoCD username"
  type        = string
  default = "admin"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD installation"
  type        = string
  default     = "openshift-gitops"
}


# variable "applications" {
#   description = "Map of ArgoCD applications to create where the key is the application name"
#   type = map(object({
#     app_name           = string
#     environment        = string
#     path               = string
#     repo_url           = optional(string)
#     target_revision    = optional(string)
#     destination_server = optional(string)
#     namespace          = optional(string)
#     helm_params        = optional(map(any))
#     automated          = optional(map(bool))
#     sync_options       = optional(list(string))
#   }))
# } 



# Vault variables


variable "k8s_jwt_auth_backend" {
  description = "Vault JWT authentication backend name used for Kubernetes"
  type        = string
  default     = "jwt"
}

variable "k8s_bound_audience" {
  type        = string
  default = "https://kubernetes.default.svc"
}


#Github variables
variable "github_organization" {
  description = "GitHub organization name"
  type        = string
  default     = "hashi-demo-lab"
}

