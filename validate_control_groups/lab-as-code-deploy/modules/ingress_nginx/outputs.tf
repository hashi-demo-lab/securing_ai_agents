# Output the Helm release name
output "ingress_nginx_release_name" {
  description = "The name of the Helm release for the ingress controller"
  value       = helm_release.ingress_nginx.name
}

# Output the namespace where NGINX ingress is deployed
output "ingress_nginx_namespace" {
  description = "The Kubernetes namespace where the NGINX ingress controller is deployed"
  value       = helm_release.ingress_nginx.namespace
}

# Output the Helm chart version used
output "ingress_nginx_chart_version" {
  description = "The version of the Helm chart deployed for the NGINX ingress controller"
  value       = helm_release.ingress_nginx.version
}

# Output the Helm release status
output "ingress_nginx_release_status" {
  description = "The current status of the Helm release for the ingress controller"
  value       = helm_release.ingress_nginx.status
}

# Output the full name of the ingress service
output "ingress_nginx_service_name" {
  description = "The full service name created by the Helm release for NGINX ingress controller"
  value       = helm_release.ingress_nginx.metadata[0].name
}

# Output the URL of the NGINX ingress controller repository
output "ingress_nginx_repository" {
  description = "The repository URL of the Helm chart used for the NGINX ingress controller"
  value       = helm_release.ingress_nginx.repository
}