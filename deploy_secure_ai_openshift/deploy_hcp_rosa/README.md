# Secure AI ROSA HCP Deployment

This Terraform module deploys a Red Hat OpenShift Service on AWS (ROSA) with Hosted Control Plane (HCP) for secure AI workloads.

## Features

- Deploys a ROSA HCP cluster with STS authentication
- Configures IAM roles for AWS account and operators
- Sets up HTPasswd identity provider for authentication
- Securely generates a random password for the default user

## Prerequisites

- AWS account with appropriate permissions
- Red Hat Cloud Console account with appropriate subscriptions
- ROSA CLI installed and configured
- Terraform v1.0.0+

## Usage

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "rosa-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "rosa" {
  source = "./deploy_secure_ai_openshift/deploy_hcp_rosa"
  
  cidr_block        = module.vpc.vpc_cidr_block
  public_subnets    = module.vpc.public_subnet_ids
  private_subnets   = module.vpc.private_subnet_ids
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  cluster_name       = "secure-ai-cluster"
  openshift_version  = "4.14.24"
  account_role_prefix = "secure-ai-account"
  operator_role_prefix = "secure-ai-operator"
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cidr_block | CIDR block for the VPC | string | "10.0.0.0/16" |
| public_subnets | List of public subnet IDs | list(string) | n/a |
| private_subnets | List of private subnet IDs | list(string) | n/a |
| availability_zones | List of availability zones to deploy the cluster into | list(string) | ["us-east-1a", "us-east-1b", "us-east-1c"] |
| cluster_name | Name of the ROSA HCP cluster | string | "my-cluster" |
| openshift_version | Version of OpenShift to deploy | string | "4.14.24" |
| account_role_prefix | Prefix for AWS IAM account roles | string | "my-cluster-account" |
| operator_role_prefix | Prefix for AWS IAM operator roles | string | "my-cluster-operator" |
| replicas | Number of compute node replicas per zone | number | 2 |
| htpasswd_idp_name | Name for the HTPasswd identity provider | string | "htpasswd-idp" |
| htpasswd_username | Username for HTPasswd authentication | string | "test-user" |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the created ROSA HCP cluster |
| cluster_domain | Domain name of the ROSA HCP cluster |
| console_url | URL for the OpenShift web console |
| api_url | URL for the OpenShift API |
| htpasswd_username | Username for HTPasswd authentication |
| htpasswd_password | Generated password for HTPasswd authentication | 