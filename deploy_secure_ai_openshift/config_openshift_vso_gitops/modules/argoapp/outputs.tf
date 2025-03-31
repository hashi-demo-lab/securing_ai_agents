output "application_name" {
  description = "Name of the created ArgoCD application"
  value       = { for k, v in argocd_application.app : k => v.metadata[0].name }
}

output "application_namespace" {
  description = "Target namespace of the application"
  value       = { for k, v in argocd_application.app : k => [for d in v.spec[0].destination : d.namespace][0] }
}

output "sync_status" {
  description = "Current sync status of the application"
  value       = { for k, v in argocd_application.app : k => v.status[0].sync[0].status }
} 