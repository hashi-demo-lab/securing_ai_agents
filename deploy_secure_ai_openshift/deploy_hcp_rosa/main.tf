module "hcp" {
  source = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.6.2"

  cluster_name           = "my-cluster"
  openshift_version      = "4.14.24"
  machine_cidr           = var.cidr_block
  aws_subnet_ids         = concat(var.public_subnets, var.private_subnets)
  aws_availability_zones = module.vpc.availability_zones
  replicas               = length(var.availability_zones)

  // STS configuration
  create_account_roles  = true
  account_role_prefix   = "my-cluster-account"
  create_oidc           = true
  create_operator_roles = true
  operator_role_prefix  = "my-cluster-operator"
}

############################
# HTPASSWD IDP
############################
module "htpasswd_idp" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/idp"

  cluster_id         = module.hcp.cluster_id
  name               = "htpasswd-idp"
  idp_type           = "htpasswd"
  htpasswd_idp_users = [{ username = "test-user", password = random_password.password.result }]
}

resource "random_password" "password" {
  length  = 14
  special = true
  min_lower = 1
  min_numeric = 1
  min_special = 1
  min_upper = 1
}