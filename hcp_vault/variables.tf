// generic variables

variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
  default     = "skoaap"
}

// hashicorp cloud platform (hcp) variables
variable "hcp_client_id" {
  description = "hcp client id"
  type        = string
}

variable "hcp_client_secret" {
  description = "hcp client secret"
  type        = string
}

variable "hcp_project_id" {
  description = "hcp project id"
  type        = string
}

variable "hcp_hvn_cidr" {
  description = "hcp hvn cidr"
  type        = string
  default     = "10.219.255.0/24"
}

variable "hcp_vault_tier" {
  description = "hcp vault cluster tier"
  type        = string
  default     = "standard_small"
}

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-west-1"
}

// amazon web services (aws) variables

variable "aws_vpc_cidr" {
  description = "aws vpc cidr"
  type        = string
  default     = "10.200.0.0/16"
}

