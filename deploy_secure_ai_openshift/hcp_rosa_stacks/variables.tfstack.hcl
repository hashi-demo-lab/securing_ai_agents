variable "region" {
  type = string
}

variable "aws_identity_token" {
  type = string
  ephemeral = true
  sensitive = true
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "openshift_version" {
  type = string
}

variable "account_role_prefix" {
  type = string
}

variable "operator_role_prefix" {
  type = string
}

variable "replicas" {
  type = number
}

variable "htpasswd_idp_name" {
  type = string
}

variable "htpasswd_username" {
  type = string
}


