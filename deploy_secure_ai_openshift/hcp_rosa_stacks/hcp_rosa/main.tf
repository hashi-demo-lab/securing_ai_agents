module "hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.6.5"

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  machine_cidr           = var.cidr_block
  aws_subnet_ids         = concat(var.public_subnets, var.private_subnets)
  aws_availability_zones = var.availability_zones
  replicas               = length(var.availability_zones)

  // STS configuration
  create_account_roles  = true
  account_role_prefix   = var.account_role_prefix
  create_oidc           = true
  create_operator_roles = true
  operator_role_prefix  = var.operator_role_prefix
}

############################
# HTPASSWD IDP
############################
module "htpasswd_idp" {
  source  = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
  version = "1.6.5"

  cluster_id         = module.hcp.cluster_id
  name               = var.htpasswd_idp_name
  idp_type           = "htpasswd"
  htpasswd_idp_users = [{ username = var.htpasswd_username, password = random_password.password.result }]
}

resource "random_password" "password" {
  length      = 14
  special     = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}