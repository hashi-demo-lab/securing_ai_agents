variable "argocd_server" {
  description = "ArgoCD server address"
  type        = string
  default     = "argocd.example.com:443"
}

variable "argocd_username" {
  description = "ArgoCD username"
  type        = string
  default     = "admin"
}

variable "argocd_password" {
  description = "ArgoCD password"
  type        = string
  sensitive   = true
  default     = null # Should be provided via environment variable or other secure method
}

variable "argocd_insecure" {
  description = "Connect to ArgoCD server without TLS verification"
  type        = bool
  default     = false
} 