variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to deploy the cluster into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "aws_region" {
  description = "AWS region where the ROSA cluster will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "rhcs_token" {
  description = "Red Hat Cloud Services API token for ROSA authentication"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the ROSA HCP cluster"
  type        = string
  default     = "my-cluster"
}

variable "openshift_version" {
  description = "Version of OpenShift to deploy"
  type        = string
  default     = "4.14.24"
}

variable "account_role_prefix" {
  description = "Prefix for AWS IAM account roles"
  type        = string
  default     = "my-cluster-account"
}

variable "operator_role_prefix" {
  description = "Prefix for AWS IAM operator roles"
  type        = string
  default     = "my-cluster-operator"
}

variable "replicas" {
  description = "Number of compute node replicas per zone"
  type        = number
  default     = 2
}

variable "htpasswd_idp_name" {
  description = "Name for the HTPasswd identity provider"
  type        = string
  default     = "htpasswd-idp"
}

variable "htpasswd_username" {
  description = "Username for HTPasswd authentication"
  type        = string
  default     = "test-user"
}
