# modules/monitoring/main.tf

# ConfigMap for Prometheus scrape configuration
resource "kubernetes_config_map_v1" "prometheus_scrape_config" {
  metadata {
    name      = "prometheus-scrape-config"
    namespace = var.prometheus_namespace
  }

  data = {
    "prometheus.yml" = var.prometheus_scrape_config
  }
}

# Secret for Prometheus CA certificate
resource "kubernetes_secret_v1" "prometheus_ca_secret" {
  metadata {
    name      = "prometheus-ca-secret"
    namespace = var.prometheus_namespace
  }

  data = {
    "ca.crt" = var.ca_cert_pem
  }

  type = "Opaque"
}

# Secret for Prometheus Vault token
resource "kubernetes_secret_v1" "prometheus_token_secret" {
  metadata {
    name      = "prometheus-token-secret"
    namespace = var.prometheus_namespace
  }

  data = {
    "token" = var.vault_root_token
  }

  type = "Opaque"
}

# Helm release for Prometheus
resource "helm_release" "prometheus" {
  depends_on = [
    kubernetes_config_map_v1.prometheus_scrape_config,
    kubernetes_secret_v1.prometheus_ca_secret,
    kubernetes_secret_v1.prometheus_token_secret,
  ]

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = var.prometheus_namespace
  version    = var.prometheus_helm_version

  values = [
    var.prometheus_helm_values
  ]
}

# ConfigMap for Grafana datasource configuration
resource "kubernetes_config_map_v1" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = var.grafana_namespace
  }

  data = {
    "datasources.yaml" = var.grafana_configmap
  }
}

# ConfigMap for Grafana dashboards
resource "kubernetes_config_map_v1" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = var.grafana_namespace
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "vault_dashboard.json" = var.grafana_dashboards
  }
}

# Secret for Grafana Vault token
resource "kubernetes_secret_v1" "grafana_token_secret" {
  metadata {
    name      = "grafana-token-secret"
    namespace = var.grafana_namespace
  }

  data = {
    "token" = var.vault_root_token
  }

  type = "Opaque"
}

# Helm release for Grafana
resource "helm_release" "grafana" {
  depends_on = [
    kubernetes_config_map_v1.grafana_config,
    kubernetes_config_map_v1.grafana_dashboards,
    kubernetes_secret_v1.grafana_token_secret,
  ]

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = var.grafana_namespace
  version    = var.grafana_helm_version

  values = [
    var.grafana_helm_values
  ]

  set {
    name  = "dashboardsConfigMaps.default"
    value = "grafana-dashboards"
  }
}

# resource "kubernetes_config_map_v1" "grafana_loki_datasource" {
#   metadata {
#     name      = "grafana-loki-datasource"
#     namespace = var.grafana_namespace
#   }

#   data = {
#     "datasources.yaml" = var.grafana_loki_config
#   }
# }

# resource "helm_release" "loki" {
#   name       = "loki"
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "loki"
#   namespace  = var.prometheus_namespace
#   version    = var.loki_helm_version

#   values = [var.loki_helm_values]
# }

# resource "helm_release" "promtail" {
#   name       = "promtail"
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "promtail"
#   namespace  = var.prometheus_namespace
#   version    = var.promtail_helm_version

#   values = [var.promtail_helm_values]
# }