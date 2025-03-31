output "application_names" {
  description = "Names of the created ArgoCD applications"
  value       = module.argocd_applications.application_name
}

output "application_namespaces" {
  description = "Target namespaces of the applications"
  value       = module.argocd_applications.application_namespace
}

output "sync_statuses" {
  description = "Current sync status of the applications"
  value       = module.argocd_applications.sync_status
}

# Example of how to access a specific application's output
output "secure_ai_service_name" {
  description = "Name of the secure-ai-service application"
  value       = module.argocd_applications.application_name["secure-ai-service"]
}

output "secure_ai_service_namespace" {
  description = "Namespace of the secure-ai-service application"
  value       = module.argocd_applications.application_namespace["secure-ai-service"]
} 