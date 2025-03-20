resource "helm_release" "vault_secrets_operator" {
  count = var.vso_helm == null ? 0 : 1

  name       = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  namespace  = var.vault_namespace
  version    = var.vault_helm_version

  values = [var.vso_helm]
}