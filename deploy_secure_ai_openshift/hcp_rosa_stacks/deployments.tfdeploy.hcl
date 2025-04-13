identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}



deployment "rosa_development" {
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    regions             = ["ap-southeast-2"]
    


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