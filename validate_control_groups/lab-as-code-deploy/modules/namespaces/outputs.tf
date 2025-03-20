# modules/namespaces/outputs.tf

output "nginx_namespace" {
  description = "The namespace for NGINX ingress"
  value       = kubernetes_namespace.namespace["nginx"].metadata[0].name
}

output "primary_vault_namespace" {
  description = "The namespace for Priamry Vault"
  value       = kubernetes_namespace.namespace["primary-vault"].metadata[0].name
}

output "auto_unseal_vault_namespace" {
  description = "The namespace for Auto Unseal Vault"
  value       = kubernetes_namespace.namespace["auto-unseal-vault"].metadata[0].name
}

output "prometheus_namespace" {
  description = "The namespace for Prometheus"
  value       = kubernetes_namespace.namespace["prometheus"].metadata[0].name
}

output "ldap_namespace" {
  description = "The namespace for LDAP"
  value       = kubernetes_namespace.namespace["ldap"].metadata[0].name
}

output "grafana_namespace" {
  description = "The namespace for Grafana"
  value       = kubernetes_namespace.namespace["grafana"].metadata[0].name
}

output "mysql_namespace" {
  description = "The namespace for MySQL"
  value       = kubernetes_namespace.namespace["mysql"].metadata[0].name
}

output "neo4j_namespace" {
  description = "The namespace for Neo4j"
  value       = kubernetes_namespace.namespace["neo4j"].metadata[0].name
}

output "gitlab_namespace" {
  description = "The namespace for GitLab"
  value       = kubernetes_namespace.namespace["gitlab"].metadata[0].name
}

# output "hostnaming-service_namespace" {
#   description = "The namespace for Hostnaming Service"
#   value       = kubernetes_namespace.namespace["hostnaming-service"].metadata[0].name
# }