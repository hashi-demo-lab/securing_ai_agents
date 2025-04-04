locals {
 repo_url = "https://github.com/hashi-demo-lab/securing_ai_agents.git"
 path       = "deploy_secure_ai_openshift/config_openshift_vso_gitops/platform"
}


# Define the Parent "App of Apps" Application
resource "argocd_application" "app_of_apps_platform" {
  metadata {
    # Name of this parent application in Argo CD UI
    name      = "app-of-apps-platform"
    # Namespace where Argo CD is running and Application CRDs exist
    namespace = "argocd"
  }

  spec {
    # Source repository containing the child application definitions
    source {
      repo_url = local.repo_url # The Git repository URL
      # The path within the repo where child app manifests are located
      path = local.path
      # Branch/tag/commit to track
      target_revision = "main" # Or "main", "master", a specific tag/commit

      # --- Key for App of Apps ---
      # Recursively search for application manifests in the path
      directory {
        recurse = true
      }
      # ---------------------------
    }

    # Destination where the *child Application CRDs* defined in the source path
    # will be created. This should be the Argo CD namespace itself.
    destination {
      server    = "https://kubernetes.default.svc" # Target cluster API server
      namespace = "argocd"                         # Child Application CRDs go here
    }

    # Argo CD Project this application belongs to
    project = "default" # Change if you use a different Argo CD project

    # Synchronization Policy for the parent app itself
    sync_policy {
      # Automated sync ensures child apps are automatically created/updated/deleted
      # based on the manifests found in the Git repository path.
      automated {
        prune      = true # Remove child apps if their definition is removed from Git
        self_heal  = true # Correct drift if someone manually changes the parent app definition
        allow_empty = false # Don't allow sync if the path becomes empty (safety check)
      }

      # Options for the sync operation itself
      sync_options = [
        "Validate=true",      # Validate resources before applying
        "CreateNamespace=true", # Needed if child apps deploy to namespaces that might not exist *yet*
        "PruneLast=true",     # Prune resources after other operations
        "ApplyOutOfSyncOnly=true" # Only apply changes if the app is OutOfSync
      ]
    }
  }
}
