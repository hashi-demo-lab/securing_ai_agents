# Kuberenetes Role required for Vault initialization script to manage secrets
# We use this to store the root token in the namespace. This is not a best practice but for demo purposes only.
resource "kubernetes_role_v1" "vault_init_role" {
  metadata {
    name      = "vault-init-role"
    namespace = var.vault_namespace
  }
  rule {
    api_groups = [""]
    resources  = ["secrets", "pods"]
    verbs      = ["create", "get", "update", "delete", "patch", "list"]
  }
}

# Binding role to default service account for Vault init
resource "kubernetes_role_binding_v1" "vault_init_role_binding" {
  metadata {
    name      = "vault-init-role-binding"
    namespace = var.vault_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.vault_init_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.vault_namespace
  }
}