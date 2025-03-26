output "vso_namespace" {
  description = "Namespace where Vault Secrets Operator is installed"
  value       = try(kubernetes_namespace.vso[0].metadata[0].name, null)
}

output "gitops_namespace" {
  description = "Namespace where OpenShift GitOps Operator is installed"
  value       = try(kubernetes_namespace.gitops_operator[0].metadata[0].name, null)
}

output "vso_status" {
  description = "Status of Vault Secrets Operator installation"
  value       = try(kubernetes_manifest.vso[0].manifest.status, "not installed")
}

output "gitops_status" {
  description = "Status of OpenShift GitOps Operator installation"
  value       = try(kubernetes_manifest.gitops_operator[0].manifest.status, "not installed")
}

output "vso_operator_manifest" {
  description = "Applied Vault Secrets Operator manifest"
  value       = try(kubernetes_manifest.vso[0].manifest, null)
  sensitive   = true
}

output "gitops_operator_manifest" {
  description = "Applied OpenShift GitOps Operator manifest"
  value       = try(kubernetes_manifest.gitops_operator[0].manifest, null)
  sensitive   = true
}
