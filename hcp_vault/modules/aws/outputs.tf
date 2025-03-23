output "tgw_id"{
  value = module.tgw.ec2_transit_gateway_id
}

output "ram_resource_share_arn" {
  value = module.tgw.ram_resource_share_id
}

output "vpc_id" {
  value = module.infra-aws.vpc_id
}

output "public_subnet_ids" {
  value = module.infra-aws.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.infra-aws.public_subnet_ids
}