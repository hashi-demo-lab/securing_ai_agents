terraform {
  required_providers {
    
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.36"
    }

    argocd = {
      source = "argoproj-labs/argocd"
      version = "~> 7.5.2"
    }

  }

  cloud { 
    
    organization = "tfo-apj-demos" 

    workspaces { 
      name = "platform-openshift-gitops" 
    } 
  } 

}