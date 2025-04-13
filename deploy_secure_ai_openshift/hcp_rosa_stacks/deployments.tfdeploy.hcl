identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}

deployment "rosa_development" {
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    regions             = ["ap-southeast-2"]
    cidr_block          = "10.0.0.0/16"
    public_subnets      = ["subnet-1", "subnet-2"]
    private_subnets     = ["subnet-3", "subnet-4"]
    availability_zones  = ["ap-southeast-2a", "ap-southeast-2b"]
    cluster_name        = "rosa-dev-cluster"
    openshift_version   = "4.12"
    account_role_prefix = "dev"
    operator_role_prefix = "dev"
    replicas           = 2
    htpasswd_idp_name   = "dev-htpasswd"
    htpasswd_username   = "dev-admin"

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