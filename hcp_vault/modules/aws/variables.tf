variable "region" {
  description = "aws region"
  type        = string
}

variable "deployment_id" {
  description = "deployment id"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
}

variable "hcp_hvn_provider_account_id" {
  description = "hcp hvn provider account id"
  type        = string
}

variable "hcp_hvn_cidr" {
  description = "hcp hvn cidr"
  type        = string
}