identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}

store "varset" "openshift_rosa" {
  id       = "varset-TC8xJVcQjbr7ux9z"
  category = "env"
}


deployment "rosa_development" {
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    regions             = ["ap-southeast-1"]
    rhcs_token        = varset.openshift_rosa.RHCS_TOKEN
    cidr_block          = "10.0.0.0/16"
    public_subnets      = ["subnet-0c0eca1ee285e4177","subnet-0874f2ae2f9c50df2","subnet-0e88e26f5d4ef35ed"]
    private_subnets = ["subnet-0c0eca1ee285e4177","subnet-0874f2ae2f9c50df2","subnet-0e88e26f5d4ef35ed",]
    rhcs_token        = identity_token.aws.jwt
    availability_zones  = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
    cluster_name        = "rosa-dev-cluster"
    openshift_version   = "4.14.24"
    account_role_prefix = "devacct"
    operator_role_prefix = "devop"
    replicas           = 2
    htpasswd_idp_name   = "dev-htpasswd"
    htpasswd_username   = "dev-htadmin" 

  }
}

# deployment "rosa_prod" {
#   inputs = {
#     aws_identity_token = identity_token.aws.jwt
#     role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
#     regions             = ["ap-southeast-2"]
#   }
# }

orchestrate "auto_approve" "safe_plans_dev" {
  check {
      # Only auto-approve in the development environment if no resources are being removed
      condition = context.plan.changes.remove == 0 && context.plan.deployment == deployment.development
      reason = "Plan has ${context.plan.changes.remove} resources to be removed."
  }
}