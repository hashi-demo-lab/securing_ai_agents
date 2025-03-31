variable "namespace" {
  description = "Namespace for ArgoCD resources"
  type        = string
  default     = "argocd"
}

variable "project_name" {
  description = "Name of the ArgoCD project"
  type        = string
}

variable "project_description" {
  description = "Description of the ArgoCD project"
  type        = string
  default     = "Project created by Terraform"
}

variable "source_repos" {
  description = "List of allowed source repositories"
  type        = list(string)
  default     = ["*"]
}

variable "project_destinations" {
  description = "List of allowed destinations for applications in this project"
  type = list(object({
    server    = string
    namespace = string
  }))
  default = [
    {
      server    = "https://kubernetes.default.svc"
      namespace = "*"
    }
  ]
}

variable "cluster_resource_whitelist" {
  description = "List of allowed cluster resources"
  type = list(object({
    group = string
    kind  = string
  }))
  default = [
    {
      group = "*"
      kind  = "*"
    }
  ]
}

variable "default_repo_url" {
  description = "Default repository URL for applications"
  type        = string
}

variable "default_target_revision" {
  description = "Default target revision (branch, tag, commit) for applications"
  type        = string
  default     = "HEAD"
}

variable "default_destination_server" {
  description = "Default destination server for applications"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "applications" {
  description = "Map of ArgoCD applications to create where the key is the application name"
  type = map(object({
    path               = string
    repo_url           = optional(string)
    target_revision    = optional(string)
    destination_server = optional(string)
    namespace          = optional(string)
    helm_params        = optional(map(any))
    automated          = optional(map(bool))
    sync_options       = optional(list(string))
  }))
} 