output "cluster_id" {
  description = "ID of the created ROSA HCP cluster"
  value       = module.hcp.cluster_id
}

output "cluster_domain" {
  description = "Domain name of the ROSA HCP cluster"
  value       = module.hcp.cluster_domain
}

output "cluster_admin_username" {
  value       = module.hcp.cluster_admin_username
  description = "The username of the admin user."
  sensitive   = true
}

output "cluster_admin_password" {
  value       = module.hcp.cluster_admin_password
  description = "The password of the admin user."
  sensitive   = true
}

output "cluster_console_url" {
  description = "URL for the OpenShift web console"
  value       = module.hcp.cluster_console_url
}

output "cluster_api_url" {
  description = "URL for the OpenShift API"
  value       = module.hcp.cluster_api_url
}

output "cluster_state" {
  value       = module.hcp.cluster_state
  description = "The state of the cluster."
}

output "oidc_endpoint_url" {
  description = "URL for the OpenID Connect endpoint"
  value       = module.hcp.oidc_endpoint_url
}

output "htpasswd_username" {
  description = "Username for HTPasswd authentication"
  value       = var.htpasswd_username
}

output "htpasswd_password" {
  description = "Generated password for HTPasswd authentication"
  value       = random_password.password.result
  sensitive   = true
}
