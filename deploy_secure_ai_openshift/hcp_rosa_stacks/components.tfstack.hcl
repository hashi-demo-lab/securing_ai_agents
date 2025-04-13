
#HCP ROSA
component "hcp_rosa" {

  source = "./hcp_rosa"

  inputs = {
    region = var.region
    cidr_block   = var.cidr_block
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
    availability_zones = var.availability_zones
    cluster_name = var.cluster_name
    openshift_version = var.openshift_version
    account_role_prefix = var.account_role_prefix
    operator_role_prefix = var.operator_role_prefix
    replicas = var.replicas
    htpasswd_idp_name = var.htpasswd_idp_name
    htpasswd_username = var.htpasswd_username
  }

  providers = {
    aws    = provider.aws.configurations
    rhcss  = provider.rhcss.this
    time = provider.time.this
    random = provider.random.this
    null = provider.null.this
  }
}


