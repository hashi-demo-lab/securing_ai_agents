variable "app_name" {
  description = "Name of the ArgoCD application"
  type        = string
}

variable "project_name" {
  description = "ArgoCD project to which the application belongs"
  type        = string
}

variable "namespace" {
  description = "Target namespace where the application will be deployed"
  type        = string
}

variable "repo_url" {
  description = "Git repository URL containing the application manifests"
  type        = string
}

variable "repo_path" {
  description = "Path within the Git repository containing the application manifests"
  type        = string
}

variable "repo_branch" {
  description = "Git branch to use"
  type        = string
  default     = "main"
}

variable "destination_server" {
  description = "Destination cluster API server URL"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "sync_policy" {
  description = "Application sync policy configuration"
  type = object({
    automated = optional(object({
      prune       = optional(bool, true)
      self_heal   = optional(bool, true)
      allow_empty = optional(bool, false)
    }), {})
    sync_options = optional(list(string), ["CreateNamespace=true"])
  })
  default = {
    automated = {
      prune       = true
      self_heal   = true
      allow_empty = false
    }
    sync_options = ["CreateNamespace=true"]
  }
} 

variable "helm_params" {
  description = "Helm specific parameters for the application"
  type = object({
    value_files  = optional(list(string), [])
    values       = optional(string, "")
    parameters   = optional(list(object({
      name  = string
      value = string
    })), [])
    release_name = optional(string, null)
  })
  default = null
} 