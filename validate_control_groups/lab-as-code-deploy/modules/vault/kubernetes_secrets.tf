resource "kubernetes_secret_v1" "vault_license" {
  metadata {
    name      = "vaultlicense"
    namespace = var.vault_namespace
  }
  data = { license = var.vault_license }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "vault_tls" {
  metadata {
    name      = "vault-certificate"
    namespace = var.vault_namespace
  }

  data = {
    "tls.crt" = var.vault_cert_pem
    "tls.key" = var.vault_private_key_pem
    "ca.crt"  = var.ca_cert_pem
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "aws_credentials" {
  count = length(var.aws_credentials) > 0 ? 1 : 0

  metadata {
    name      = "aws-credentials"
    namespace = var.vault_namespace
  }

  data = {
    AWS_ACCESS_KEY_ID     = lookup(var.aws_credentials, "access_key", "")
    AWS_SECRET_ACCESS_KEY = lookup(var.aws_credentials, "secret_key", "")
    AWS_SESSION_TOKEN     = lookup(var.aws_credentials, "session_token", "")
  }

  type = "Opaque"
}

data "kubernetes_secret" "auto_unseal_token" {
  count = var.vault_mode == "primary" ? 1 : 0

  metadata {
    name      = "vault-seal-token"
    namespace = "auto-unseal-vault" # This is the auto-unseal namespace.
  }
}

data "kubernetes_secret" "vault_init_credentials" {
  depends_on = [kubernetes_job_v1.vault_initialization]
  metadata {
    name      = "vault-init-credentials"
    namespace = var.vault_namespace
  }
}