


locals {
  # Define the Vault namespace for the application
  #app_identifier = "${var.app_name}${var.environment}"
}


# identity per application service account
# resource "vault_jwt_auth_backend_role" "app_id" {
#   for_each = {
    
#   }
#   backend                 = var.k8s_jwt_auth_backend
#   role_name               = "${local.app_identifier}-role"
#   role_type               = "jwt"
#   bound_audiences         = ["${var.k8s_bound_audience}"]
#   user_claim              = "/kubernetes.io/serviceaccount/name"
#   user_claim_json_pointer = true
#   token_policies          = ["${local.app_identifier}-policy"]

#   # Allows wildcards or regex in bound_claims
#   bound_claims_type = "glob"

#   bound_claims = {
#     # Match any service account starting with "${app_identifier}-service-"
#     "/kubernetes.io/serviceaccount/name" = "${local.app_identifier}-service-*"
#     # Restrict to the "${app_identifier}" namespace
#     "/kubernetes.io/namespace" = "${local.app_identifier}"
#   }
# }
