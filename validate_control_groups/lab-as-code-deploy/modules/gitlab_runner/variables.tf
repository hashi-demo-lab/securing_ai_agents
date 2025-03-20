variable "namespace" {
  description = "Namespace for GitLab Runner installation"
  type        = string
}

variable "release_name" {
  description = "Helm release name for GitLab Runner"
  type        = string
  default     = "gitlab-runner"
}

variable "chart_version" {
  description = "Version of the GitLab Runner Helm chart"
  type        = string
  default     = "0.64.0"  # Adjust to your required version
}

variable "runner_registration_token" {
  description = "GitLab runner registration token"
  type        = string
  sensitive   = true  # Hides the token value from output
}

variable "gitlab_runner_helm_values" {
  description = "Helm values for GitLab Runner deployment"
  type        = string  
}