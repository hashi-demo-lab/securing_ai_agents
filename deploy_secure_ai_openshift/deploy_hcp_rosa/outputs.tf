output "cluster_id" {
  description = "ID of the created ROSA HCP cluster"
  value       = module.hcp.cluster_id
}

output "cluster_domain" {
  description = "Domain name of the ROSA HCP cluster"
  value       = module.hcp.domain
}

output "console_url" {
  description = "URL for the OpenShift web console"
  value       = module.hcp.console_url
}

output "api_url" {
  description = "URL for the OpenShift API"
  value       = module.hcp.api_url
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
