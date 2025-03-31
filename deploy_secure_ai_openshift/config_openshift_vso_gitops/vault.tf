






resource "vault_jwt_auth_backend_role" "app1_role" {
  backend                 = var.k8s_jwt_auth_backend
  role_name               = "app1"
  role_type               = "jwt"
  bound_audiences         = ["https://kubernetes.default.svc.cluster.local"]
  user_claim              = "/kubernetes.io/serviceaccount/name"
  user_claim_json_pointer = true
  token_policies          = ["access-all"]

  # Allows wildcards or regex in bound_claims
  bound_claims_type = "glob"

  bound_claims = {
    # Match any service account starting with "app1-service-"
    "/kubernetes.io/serviceaccount/name" = "app1-service-*"
    # Restrict to the "app1" namespace
    "/kubernetes.io/namespace" = "app1"
  }
}
