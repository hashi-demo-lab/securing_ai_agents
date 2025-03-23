data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "~> 5.0"

  name                    = var.deployment_id
  cidr                    = var.vpc_cidr
  azs                     = local.azs
  private_subnets         = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_subnets          = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true
}