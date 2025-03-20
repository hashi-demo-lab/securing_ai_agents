variable "helm_release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "ingress-nginx"
}

variable "helm_repository" {
  description = "Repository URL for the Helm chart"
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "helm_chart_name" {
  description = "Name of the Helm chart"
  type        = string
  default     = "ingress-nginx"
}

variable "ingress_namespace" {
  description = "Kubernetes namespace for the ingress controller"
  type        = string
}

variable "controller_watch_namespace" {
  description = "Namespace that the ingress controller should watch (empty means all namespaces)"
  type        = string
  default     = ""
}

variable "enable_ssl_passthrough" {
  description = "Whether to enable SSL passthrough in the ingress controller"
  type        = bool
  default     = true
}

variable "ca_cert_pem" {
  description = "The CA certificate in PEM format used for TLS trust."
  type        = string
}
