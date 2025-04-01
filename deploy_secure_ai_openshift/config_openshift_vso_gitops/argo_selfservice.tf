# Variables
variable "teams" {
  type = map(object({
    name           = string
    repo_name      = string
    repo_visibility = string
    namespace_name = string
  }))
  default = {
    "team-a" = {
      name     = "team-a"
      namespace_name = "team-a"
      repo_visibility = "public"
      repo_name      = "team-a-repo"
      
    },
    "team-b" = {
      name     = "team-a"
      namespace_name = "team-a"
      repo_visibility = "public"
      repo_name      = "team-b-repo" 
     },
  }
}

# Git Repository Creation (Example using GitHub)
resource "github_repository" "team_repos" {
  for_each = var.teams
  name       = each.value.repo_name

  visibility = each.value.repo_visibility
}
# # Kubernetes Namespaces
# resource "kubernetes_namespace" "team_namespaces" {
#   for_each = var.teams
#   metadata {
#     name = each.value.namespace_name
#   }
# }

# Argo CD Projects
resource "argocd_project" "team_projects" {
  for_each = var.teams
  metadata {
    name = "${each.key}-project"
  }
  spec {
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = each.value.namespace_name
    }
    source_repos = [
      "https://github.com/${each.value.repo_owner}/${each.value.repo_name}.git",
    ]
  }
}

# Argo CD ApplicationSets
resource "argocd_application_set" "team_appsets" {
  for_each = var.teams

  metadata {
    name      = "${each.key}-appset"
    namespace = "argocd"
  }

  spec {
    
    generator {
      git {
        repo_url  = "https://github.com/${each.value.repo_owner}/${each.value.repo_name}.git"
        revision  = "HEAD"
        directory {
          path = "*" # find all applications in the team's repo
        }
      }
    }

    template {
      metadata {
        name      = "{{path.basename}}"
        namespace = "argocd"
      }
      spec {
        project = "${each.key}-project"
        source {
          repo_url        = "https://github.com/${each.value.repo_owner}/${each.value.repo_name}.git"
          target_revision = "HEAD"
          path            = "{{path.path}}"
        }
        destination {
          server    = "https://kubernetes.default.svc"
          namespace = each.value.namespace_name
        }
        sync_policy {
          automated {
            prune      = true
            self_heal  = true
          }
        }
      }
    }
  }
}

# # Kubernetes RBAC (Example: granting edit access to team namespaces)
# resource "kubernetes_role_binding" "team_deploy_access" {
#   for_each = var.teams
#   metadata {
#     name      = "${each.key}-deploy-access"
#     namespace = each.value.namespace_name
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "edit"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "default"
#     namespace = each.value.namespace_name
#   }
# }
