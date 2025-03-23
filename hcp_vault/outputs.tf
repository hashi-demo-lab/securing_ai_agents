// generic outputs

output "deployment_id" {
  description = "deployment id"
  value       = local.deployment_id
}

// hcp vault outputs

output "hcp_vault_public_fqdn" {
  description = "hcp vault public fqdn"
  value       = module.vault-hcp.public_endpoint_url
}

output "hcp_vault_private_fqdn" {
  description = "hcp vault private fqdn"
  value       = module.vault-hcp.private_endpoint_url
}

output "hcp_vault_root_token" {
  description = "hcp vault root token"
  value       = module.vault-hcp.root_token
  sensitive   = true
}

output "aws_vpc_id" {
  description = "aws vpc id"
  value       = module.infra-aws.vpc_id
}

output "aws_public_subnet_ids" {
  description = "aws public subnet ids"
  value       = module.infra-aws.public_subnets
}

output "aws_private_subnet_ids" {
  description = "aws privatelic subnet ids"
  value       = module.infra-aws.private_subnets
}


# output "packer_env_commands" {
#   description = "lab command helpers"
#   value = [
#     "export PKR_VAR_vpc_id='${module.infra-aws.vpc_id}'",
#     "export PKR_VAR_public_subnet_id='${module.infra-aws.public_subnet_ids[0]}'",
#   ]
  
# }