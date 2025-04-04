locals {
 repo_url = "https://github.com/hashi-demo-lab/securing_ai_agents.git"
 path       = "deploy_secure_ai_openshift/config_openshift_vso_gitops/platform"
}


variable "platform_namespaces" {
  description = "Map of platform namespaces to be created"
  type=set(string)
  default = [
    "argocd",
    "default",
    "openshift-gitops",
    "openshift-operators",
    "openshift-logging",
    "openshift-monitoring",
    "openshift-user-workload-monitoring",
    "openshift-virtualization",
    "kube-system"
  ]
}

variable "platform_project_name" {
  description = "Name of the Argo CD project"
  type        = string
  default     = "platform-project"
}

# Argo CD Projects
resource "argocd_project" "platform" {

  metadata {
    name = "${var.platform_project_name}"
  }
  spec {
    description = "platform team cluster project"
    dynamic "destination" {
      for_each = var.platform_namespaces
      content {
        name = "in-cluster"
        server    = "https://kubernetes.default.svc"
        namespace = destination.key
      }
    }
    source_repos = [
      "${local.repo_url}" # The Git repository URL,
    ]
  }
}

# Git repository - demo app
resource "argocd_repository" "platform_repo" {
  repo = local.repo_url
  type = "git"
}



# Define the Parent "App of Apps" Application
resource "argocd_application" "platform" {
  metadata {
    # Name of this parent application in Argo CD UI
    name      = "platform"
  }

  spec {
    # Argo CD Project this application belongs to
    project = argocd_project.platform.metadata[0].name # Change if you use a different Argo CD project
    
    source {
      repo_url = local.repo_url # The Git repository URL

      # The path within the repo where child app manifests are located
      path = local.path
      # Branch/tag/commit to track
      target_revision = "HEAD"

      directory {
        recurse = true
      }
      # ---------------------------
    }

    # Destination where the *child Application CRDs* defined in the source path
    destination {
      server    = "https://kubernetes.default.svc" # Target cluster API server
      namespace = "argocd"                         # Child Application CRDs go here
    }

    

    # Synchronization Policy for the parent app itself
    sync_policy {
      # Automated sync ensures child apps are automatically created/updated/deleted
      automated {
        prune      = true # Remove child apps if their definition is removed from Git
        self_heal  = true # Correct drift if someone manually changes the parent app definition
        allow_empty = false # Don't allow sync if the path becomes empty (safety check)
      }

      # Options for the sync operation itself
      sync_options = [
        "Validate=false",      # Validate resources before applying
        "CreateNamespace=true", # Needed if child apps deploy to namespaces that might not exist *yet*
        "PruneLast=true",     # Prune resources after other operations
        "ApplyOutOfSyncOnly=true" # Only apply changes if the app is OutOfSync
      ]
    }
  }
}
