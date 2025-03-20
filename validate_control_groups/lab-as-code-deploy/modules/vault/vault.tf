locals {
  is_primary = var.vault_mode == "primary"

  # Only assign auto-unseal values if configure_seal is enabled
  auto_unseal_addr     = var.configure_seal ? var.auto_unseal_addr : ""
  auto_unseal_key_name = var.configure_seal ? var.auto_unseal_key_name : ""
  auto_unseal_token = local.is_primary && var.configure_seal ? try(data.kubernetes_secret.auto_unseal_token[0].data["token"], "") : ""

  vault_helm_values = templatefile("${path.module}/vault_helm.tftpl", {
    namespace                   = var.vault_namespace
    vault_common_name           = var.vault_common_name
    vault_ha_enabled            = var.vault_ha_enabled
    enable_service_registration = var.enable_service_registration
    vault_replicas              = var.vault_replicas
    configure_seal              = var.configure_seal
    auto_unseal_addr            = local.auto_unseal_addr
    auto_unseal_key_name        = local.auto_unseal_key_name
    auto_unseal_token           = local.auto_unseal_token
    vault_mode                  = var.vault_mode
    aws_credentials             = var.aws_credentials
  })
}


resource "helm_release" "vault" {
  depends_on = [
    kubernetes_secret_v1.vault_license,
    kubernetes_secret_v1.vault_tls
  ]
  name       = var.vault_release_name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = var.vault_namespace
  version    = var.vault_helm_version
  values     = [local.vault_helm_values]
}