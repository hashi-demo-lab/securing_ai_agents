# Uncomment to deploy the Vault Benchmark tool
resource "kubernetes_config_map" "config" {
  count = var.vault_mode == "primary" ? 1 : 0
  metadata {
    name = "benchmark"
    namespace = var.vault_namespace
  }
  data = {
    "benchmark.hcl" = file("${path.module}/benchmark.hcl")
  }
}

resource "kubernetes_config_map" "cacert" {
  metadata {
    name      = "vault-cacert"
    namespace = var.vault_namespace
  }
  data = {
    "ca.pem" = var.ca_cert_pem
  }
}


resource "time_sleep" "wait" {
  depends_on = [ kubernetes_job_v1.vault_initialization ]
  count = var.vault_mode == "primary" ? 1 : 0
  create_duration = "30s"
}

# Benchmark Job
resource "kubernetes_job" "benchmark" {
  depends_on = [ kubernetes_job_v1.vault_initialization, time_sleep.wait ]
  count = var.vault_mode == "primary" ? 1 : 0
  metadata {
    name = "benchmark"
    namespace = var.vault_namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "benchmark"
          image   = "hashicorp/vault-benchmark"
          command = [
            "vault-benchmark",
            "run",
            "-ca_pem_file=/etc/certs/ca.pem",
            "-config=/opt/vault-benchmark/configs/benchmark.hcl"
          ]

          env {
            name  = "VAULT_CACERT"
            value = "/etc/certs/ca.pem"
          }

          volume_mount {
            mount_path = "/opt/vault-benchmark/configs/"
            name       = "config"
          }

          volume_mount {
            mount_path = "/etc/certs"
            name       = "cacert"
          }
        }

        restart_policy = "OnFailure"

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.config[0].metadata[0].name
          }
        }

        volume {
          name = "cacert"
          config_map {
            name = kubernetes_config_map.cacert.metadata[0].name
          }
        }
      }
    }
  }
  wait_for_completion = false
}