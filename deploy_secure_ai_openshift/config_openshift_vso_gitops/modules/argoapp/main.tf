# Create an ArgoCD project
resource "argocd_project" "project" {
  metadata {
    name      = var.project_name
    namespace = var.namespace
  }

  spec {
    description = var.project_description

    source_repos = var.source_repos

    # Define allowed destinations
    dynamic "destination" {
      for_each = var.project_destinations
      content {
        server    = destination.value.server
        namespace = destination.value.namespace
      }
    }
    
    # Define cluster resource whitelist
    dynamic "cluster_resource_whitelist" {
      for_each = var.cluster_resource_whitelist
      content {
        group = cluster_resource_whitelist.value.group
        kind  = cluster_resource_whitelist.value.kind
      }
    }
  }
}

# Create multiple ArgoCD applications
resource "argocd_application" "app" {
  for_each = var.applications
  
  metadata {
    name      = each.key
    namespace = var.namespace
  }

  spec {
    project = argocd_project.project.metadata[0].name

    source {
      repo_url        = lookup(each.value, "repo_url", var.default_repo_url)
      path            = each.value.path
      target_revision = lookup(each.value, "target_revision", var.default_target_revision)

      dynamic "helm" {
        for_each = lookup(each.value, "helm_params", null) != null ? [each.value.helm_params] : []
        content {
          value_files  = helm.value["value_files"]
          values       = helm.value["values"]
          release_name = helm.value["release_name"]
        }
      }
    }

    destination {
      server    = lookup(each.value, "destination_server", var.default_destination_server)
      namespace = lookup(each.value, "namespace", var.namespace)
    }

    sync_policy {
      dynamic "automated" {
        for_each = lookup(each.value, "automated", null) != null ? [each.value.automated] : []
        content {
          prune       = lookup(automated.value, "prune", false)
          self_heal   = lookup(automated.value, "self_heal", false)
          allow_empty = lookup(automated.value, "allow_empty", false)
        }
      }

      sync_options = lookup(each.value, "sync_options", [])
    }
  }
  
  depends_on = [argocd_project.project]
} 