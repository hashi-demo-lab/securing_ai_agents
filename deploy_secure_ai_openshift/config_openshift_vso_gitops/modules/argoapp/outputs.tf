output "application_name" {
  description = "Name of the created ArgoCD application"
  value       = argocd_application.app.metadata[0].name
}

output "application_namespace" {
  description = "Target namespace of the application"
  value       = [for d in argocd_application.app.spec[0].destination : d.namespace][0]
}

output "sync_status" {
  description = "Current sync status of the application"
  value       = argocd_application.app.status[0].sync[0].status
} 