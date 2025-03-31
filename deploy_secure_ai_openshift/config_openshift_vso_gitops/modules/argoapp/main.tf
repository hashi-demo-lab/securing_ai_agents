resource "argocd_application" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  spec {
    project = var.project_name

    source {
      repo_url        = var.repo_url
      path           = var.repo_path
      target_revision = var.repo_branch

      dynamic "helm" {
        for_each = var.helm_params != null ? [var.helm_params] : []
        content {
          value_files  = helm.value["value_files"]
          values       = helm.value["values"]
          release_name = helm.value["release_name"]
        }
      }
    }

    destination {
      server    = var.destination_server
      namespace = var.namespace
    }

    sync_policy {
      dynamic "automated" {
        for_each = var.sync_policy.automated != null ? [var.sync_policy.automated] : []
        content {
          prune       = automated.value.prune
          self_heal   = automated.value.self_heal
          allow_empty = automated.value.allow_empty
        }
      }

      sync_options = var.sync_policy.sync_options
    }
  }
} 