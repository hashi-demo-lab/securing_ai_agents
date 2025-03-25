variable "cluster_api_url" {
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
