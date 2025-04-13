
#HCP ROSA
component "hcp_rosa" {
  for_each = var.regions

  source = "./hcp_rosa"

  inputs = {
    region = each.value
    name   = "${var.name}-${each.value}"
    tags   = var.tags

    # HCP ROSA specific inputs
    rosa_cluster_name = "${var.name}-${each.value}"
    rosa_region      = each.value
    rosa_version     = var.rosa_version
    rosa_instance_type = var.rosa_instance_type
    rosa_node_count  = var.rosa_node_count

    # AWS specific inputs
    aws_access_key_id     = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key

  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    kubernetes  = provider.kubernetes.this
    time = provider.time.this
    null = provider.null.this
    tls = provider.tls.this
  }
}


