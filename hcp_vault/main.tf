locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "hcp-hvn" {
  source = "./modules/hcp"

  region                     = var.aws_region
  deployment_id              = local.deployment_id
  cidr                       = var.hcp_hvn_cidr
  aws_vpc_cidr               = var.aws_vpc_cidr
  aws_tgw_id                 = module.infra-aws.tgw_id
  aws_ram_resource_share_arn = module.infra-aws.ram_resource_share_arn
}

module "infra-aws" {
  source  = "./modules/aws"
  
  region                      = var.aws_region
  deployment_id               = local.deployment_id
  vpc_cidr                    = var.aws_vpc_cidr
  hcp_hvn_provider_account_id = module.hcp-hvn.provider_account_id
  hcp_hvn_cidr                = var.hcp_hvn_cidr
}

module "vault-hcp" {
  source = "./modules/vault"

  deployment_name = var.deployment_name
  hvn_id          = module.hcp-hvn.id
  tier            = var.hcp_vault_tier
}

resource "local_file" "outputs" {
  content  = jsonencode({
    deployment_id = local.deployment_id,
    hcp_vault_public_fqdn = module.vault-hcp.public_endpoint_url,
    hcp_vault_private_fqdn = module.vault-hcp.private_endpoint_url,
    hcp_vault_root_token = module.vault-hcp.root_token,
  })
  filename = "${path.root}/../deployment_outputs.json.tmp"
}