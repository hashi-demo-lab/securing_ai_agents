terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
  }

  cloud { 
    
    organization = "tfo-apj-demos" 

    workspaces { 
      name = "platform-openshift-gitops" 
    } 
  } 

}