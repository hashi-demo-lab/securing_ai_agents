output "tgw_id"{
  value = module.tgw.ec2_transit_gateway_id
}

output "ram_resource_share_arn" {
  value = module.tgw.ram_resource_share_id
}

output "vpc_id" {
  description = "aws vpc_id"
  value = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public Subnets IDs"
  value = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private Subnets IDs"
  value = module.vpc.public_subnets
}