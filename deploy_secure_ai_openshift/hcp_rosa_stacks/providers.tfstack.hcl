required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }

  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = "~> 2.25"
  }

  time = {
    source = "hashicorp/time"
    version = "~> 0.1"
  }
  

}

provider "aws" "configurations" {
  for_each = var.regions

  config {
    region = each.value

    assume_role_with_web_identity {
      role_arn                = var.role_arn
      web_identity_token = var.aws_identity_token
    }
  }
}

provider "kubernetes" "configurations" {
  for_each = var.regions
  config { 
    host                   = component.eks[each.value].cluster_endpoint
    cluster_ca_certificate = base64decode(component.eks[each.value].cluster_certificate_authority_data)
    token   = component.eks[each.value].eks_token
  }
}

provider "random" "this" {}
provider "kubernetes" "this" {}
provider "time" "this" {} 
provider "null" "this" {}