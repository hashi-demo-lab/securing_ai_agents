terraform {
  required_providers {
    
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    argocd = {
      source = "argoproj-labs/argocd"
      version = "~> 7.5"
    }

    github = {
      source = "integrations/github"
      version = "~> 6.6"
    }

  }

  cloud { 
    
    organization = "tfo-apj-demos" 

    workspaces { 
      name = "platform-openshift-gitops" 
    } 
  } 

}