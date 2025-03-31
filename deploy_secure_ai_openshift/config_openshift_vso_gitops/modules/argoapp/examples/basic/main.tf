provider "argocd" {
  server_addr = var.argocd_server
  username    = var.argocd_username
  password    = var.argocd_password
  insecure    = var.argocd_insecure
}

module "argocd_applications" {
  source = "../../modules/argoapp"

  namespace           = "argocd"
  project_name        = "secure-ai"
  project_description = "Secure AI applications managed by ArgoCD"
  
  source_repos = [
    "https://github.com/example/secure-ai-gitops",
    "https://github.com/example/helm-charts"
  ]
  
  project_destinations = [
    {
      server    = "https://kubernetes.default.svc"
      namespace = "secure-ai"
    },
    {
      server    = "https://kubernetes.default.svc"
      namespace = "secure-ai-monitoring"
    }
  ]
  
  cluster_resource_whitelist = [
    {
      group = "*"
      kind  = "*"
    }
  ]
  
  default_repo_url            = "https://github.com/example/secure-ai-gitops"
  default_target_revision     = "main"
  default_destination_server  = "https://kubernetes.default.svc"
  
  applications = {
    "secure-ai-service" = {
      path       = "applications/secure-ai-service"
      namespace  = "secure-ai"
      helm_params = {
        value_files  = ["values.yaml", "values-prod.yaml"]
        values       = "ingress:\n  enabled: true\n  host: secure-ai.example.com"
        release_name = "secure-ai-service"
      }
      automated = {
        prune       = true
        self_heal   = true
        allow_empty = false
      }
      sync_options = ["CreateNamespace=true"]
    },
    "secure-ai-monitoring" = {
      path       = "applications/monitoring"
      namespace  = "secure-ai-monitoring"
      automated = {
        prune     = true
        self_heal = true
      }
    }
  }
} 