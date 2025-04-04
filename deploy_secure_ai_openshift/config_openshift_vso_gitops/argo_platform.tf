locals {
  repo_owner = "your-github-username"
 repo_name  = "your-repo-name"
}


resource "argocd_application_set" "platform_appsets" {
  metadata {
    name      = "platform-appset"
    namespace = "argocd"
  }

  spec {
    
    generator {
      git {
        repo_url  = "https://github.com/${local.repo_owner}/${local.rep_name}.git"
        revision  = "HEAD"
        directory {
            # path should be the sub folder in the repo where the application manifests are stored 

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
          repo_url        = "https://github.com/${local.repo_owner}/${local.rep_name}.git"
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