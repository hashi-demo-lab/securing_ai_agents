resource "kubernetes_config_map_v1" "vault_initialization_script" {
  metadata {
    name      = "vault-initialization-script"
    namespace = var.vault_namespace
  }
  data = { "vault-initialization.sh" = var.vault_initialization_script }
}

resource "kubernetes_config_map_v1" "auto_unseal_config_script" {
  metadata {
    name      = "auto-unseal-config-script"
    namespace = var.vault_namespace
  }
  data = { "auto_unseal_config.sh" = var.auto_unseal_config_script }
}

# Kubernetes job to initialize Vault
resource "kubernetes_job_v1" "vault_initialization" {
  depends_on = [kubernetes_role_binding_v1.vault_init_role_binding, helm_release.vault]
  metadata {
    generate_name = "vault-initialization-${var.vault_namespace}"
    namespace     = var.vault_namespace
  }
  spec {
    template {
      metadata {
        labels = { app = "vault-init" }
      }
      spec {
        restart_policy = "Never"
        container {
          name    = "vault-init"
          image   = "hashicorp/vault:latest"
          command = ["/bin/sh", "/vault-init/vault-initialization.sh"]
          env {
            name  = "K8S_NAMESPACE"
            value = var.vault_namespace
          }
          env {
            name  = "VAULT_RELEASE_NAME"
            value = var.vault_release_name
          }
          env {
            name = "VAULT_MODE"
            value = var.vault_mode
          }
          volume_mount {
            name       = "vault-initialization-script"
            mount_path = "/vault-init"
            read_only  = true
          }
          volume_mount {
            name       = "vault-tls"
            mount_path = "/vault/tls"
            read_only  = true
          }
        }
        volume {
          name = "vault-initialization-script"
          config_map {
            name = "vault-initialization-script"
            items {
              key  = "vault-initialization.sh"
              path = "vault-initialization.sh"
            }
          }
        }
        volume {
          name = "vault-tls"
          secret {
            secret_name = "vault-certificate"
            items {
              key  = "ca.crt"
              path = "ca.crt"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_job_v1" "auto_unseal_transit_config" {
  count = var.vault_mode == "auto_unseal" ? 1 : 0
  depends_on = [kubernetes_job_v1.vault_initialization]

  metadata {
    name      = "auto-unseal-config-job"
    namespace = var.vault_namespace
  }
  spec {
    template {
      metadata {
        labels = { app = "auto-unseal-config" }
      }
      spec {
        restart_policy = "Never"
        container {
          name    = "auto-unseal-config"  # Changed: no underscores
          image   = "hashicorp/vault:latest"
          command = ["/bin/sh", "/auto-unseal-config/auto_unseal_config.sh"]
          env {
            name  = "VAULT_CACERT"
            value = "/vault/tls/ca.crt"
          }
          env {
            name  = "VAULT_ADDR"
            value = "https://auto-unseal-vault-0.auto-unseal-vault-internal.auto-unseal-vault.svc.cluster.local:8200"
          }
          env {
            name  = "VAULT_TOKEN"
            value = data.kubernetes_secret.vault_init_credentials.data["root-token"]
          }
          env {
            name  = "AUTO_UNSEAL_KEY_NAME"
            value = var.auto_unseal_key_name
          }
          volume_mount {
            name       = "auto-unseal-config-script"  # Changed: underscores -> hyphens
            mount_path = "/auto-unseal-config"
            read_only  = true
          }
          volume_mount {
            name       = "vault-tls"
            mount_path = "/vault/tls"
            read_only  = true
          }
        }
        volume {
          name = "auto-unseal-config-script"  # Changed: underscores -> hyphens
          config_map {
            name = kubernetes_config_map_v1.auto_unseal_config_script.metadata[0].name
            items {
              key  = "auto_unseal_config.sh"
              path = "auto_unseal_config.sh"
            }
          }
        }
        volume {
          name = "vault-tls"
          secret {
            secret_name = "vault-certificate"
            items {
              key  = "ca.crt"
              path = "ca.crt"
            }
          }
        }
      }
    }
  }
}
