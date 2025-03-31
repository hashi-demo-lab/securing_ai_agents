# Basic ArgoCD Applications Example

This example demonstrates how to use the ArgoCD application module to create a project and multiple applications for a secure AI deployment.

## Usage

```hcl
module "argocd_applications" {
  source = "../../modules/argoapp"

  namespace           = "argocd"
  project_name        = "secure-ai"
  project_description = "Secure AI applications managed by ArgoCD"
  
  # Define which Git repositories are allowed as sources
  source_repos = [
    "https://github.com/example/secure-ai-gitops",
    "https://github.com/example/helm-charts"
  ]
  
  # Define which clusters/namespaces applications can be deployed to
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
  
  # Define which Kubernetes resources are allowed to be managed
  cluster_resource_whitelist = [
    {
      group = "*"
      kind  = "*"
    }
  ]
  
  # Default values for all applications
  default_repo_url            = "https://github.com/example/secure-ai-gitops"
  default_target_revision     = "main"
  default_destination_server  = "https://kubernetes.default.svc"
  
  # Define the applications to be created
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
```

## Required Providers

This example uses the ArgoCD provider to interact with an ArgoCD instance. Make sure to configure the provider before using the module:

```hcl
provider "argocd" {
  server_addr = var.argocd_server
  username    = var.argocd_username
  password    = var.argocd_password
  insecure    = var.argocd_insecure
}
```

## Inputs

Refer to the `variables.tf` file for details on configuration options.

## Outputs

The module exports the following outputs:

- `application_name`: A map of application names, keyed by the application key
- `application_namespace`: A map of application target namespaces, keyed by the application key
- `sync_status`: A map of application sync statuses, keyed by the application key

Example usage:

```hcl
output "secure_ai_service_name" {
  description = "Name of the secure-ai-service application"
  value       = module.argocd_applications.application_name["secure-ai-service"]
}
``` 