variable "region" {
  description = "hcp hvn region"
  type        = string
}

variable "deployment_id" {
  description = "deployment id"
  type        = string
}

variable "cidr" {
  description = "hcp hvn cidr"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "aws vpc cidr"
  type        = string
}

variable "aws_tgw_id"{
  description = "aws ec2 transit gateway id"
  type        = string
}

variable "aws_ram_resource_share_arn" {
  description = "aws resource name (arn) of the resource share"
  type        = string
}