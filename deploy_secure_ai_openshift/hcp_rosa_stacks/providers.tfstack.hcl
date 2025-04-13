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
  random = {
    source = "hashicorp/random"
    version = "~> 3.0"
  }
  null = {
    source = "hashicorp/null"
    version = "~> 3.0"
  }
  rhcss = {
    source = "hashicorp/rhcss"
    version = "~> 0.1"
  }
  

}

provider "aws" "configurations" {

  config {
    region = var.region

    assume_role_with_web_identity {
      role_arn                = var.role_arn
      web_identity_token = var.aws_identity_token
    }
  }
}

# provider "kubernetes" "configurations" {
#   for_each = var.regions
#   config { 
#     host                   = component.eks[each.value].cluster_endpoint
#     cluster_ca_certificate = base64decode(component.eks[each.value].cluster_certificate_authority_data)
#     token   = component.eks[each.value].eks_token
#   }
# }
#provider "kubernetes" "this" {}

provider "random" "this" {}
provider "time" "this" {} 
provider "null" "this" {}
provider "rhcss" "this" {}