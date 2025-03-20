# # main.tf

module "namespaces" {
  source = "./modules/namespaces"
}

module "ingress_nginx" {
  source            = "./modules/ingress_nginx"
  ingress_namespace = module.namespaces.nginx_namespace
  ca_cert_pem       = data.local_file.root_ca_cert.content
}

# Generate a certificate for auto_unseal_vault using the Root CA
module "auto_unseal_vault_cert" {
  source                = "github.com/hashi-demo-lab/terraform-cert-creation.git?ref=main"
  ca_private_key_pem    = data.local_file.root_ca_key.content
  ca_cert_pem           = data.local_file.root_ca_cert.content
  common_name           = var.auto_unseal_vault_common_name
  dns_names             = var.auto_unseal_vault_dns_names
  organization          = var.organization
  is_ca_certificate     = false
  validity_period_hours = 8760
  cert_file_name        = "${path.root}/../certificates/auto_unseal_vault.crt"
  key_file_name         = "${path.root}/../certificates/auto_unseal_vault.key"
  save_to_file          = true
}

module "auto_unseal_vault" {
  source          = "./modules/vault"
  depends_on      = [module.ingress_nginx]
  vault_namespace = module.namespaces.auto_unseal_vault_namespace

  # Pass the certificate and key data from the auto_unseal_vault_cert module.
  ca_cert_pem           = data.local_file.root_ca_cert.content
  vault_cert_pem        = module.auto_unseal_vault_cert.cert_pem
  vault_private_key_pem = module.auto_unseal_vault_cert.private_key_pem

  vault_dns_names   = var.auto_unseal_vault_dns_names
  vault_common_name = var.auto_unseal_vault_common_name
  organization      = var.organization

  # For auto‑unseal, deploy as a single‑node (HA disabled).
  vault_license                     = var.vault_license
  vault_release_name                = "auto-unseal-vault"
  vault_ha_enabled                  = false
  vault_initialization_script       = local.auto_unseal_vault_init_script
  auto_unseal_transit_config_script = local.auto_unseal_transit_config_script
  configure_seal                    = false
  vault_mode                        = "auto_unseal"
  enable_service_registration       = false #Non HA mode does not require service registration
}

module "primary_vault_cert" {
  source                = "github.com/hashi-demo-lab/terraform-cert-creation.git?ref=main"
  ca_private_key_pem    = data.local_file.root_ca_key.content
  ca_cert_pem           = data.local_file.root_ca_cert.content
  common_name           = var.primary_vault_common_name
  dns_names             = var.primary_vault_dns_names
  organization          = var.organization
  is_ca_certificate     = false
  validity_period_hours = 8760
  cert_file_name        = "${path.root}/../certificates/vault.crt"
  key_file_name         = "${path.root}/../certificates/vault.key"
  save_to_file          = true
}

module "primary_vault" {
  source     = "./modules/vault"
  depends_on = [module.auto_unseal_vault]

  vault_namespace = module.namespaces.primary_vault_namespace

  # Pass the certificate and key data from the primary_vault_cert module
  ca_cert_pem           = data.local_file.root_ca_cert.content
  vault_cert_pem        = module.primary_vault_cert.cert_pem
  vault_private_key_pem = module.primary_vault_cert.private_key_pem

  organization      = var.organization
  vault_dns_names   = var.primary_vault_dns_names
  vault_common_name = var.primary_vault_common_name

  vault_license               = var.vault_license
  vso_helm                    = local.vso_helm_values
  vault_initialization_script = local.primary_vault_init_script
  configure_seal              = true
  vault_mode                  = "primary"
  enable_service_registration = true
  aws_credentials             = var.aws_credentials
}

data "onepassword_vault" "vault_lab" {
  name = "Vault Lab"
}

resource "onepassword_item" "vault_root_token" {
  vault    = data.onepassword_vault.vault_lab.uuid
  title    = "HashiCorp Vault Lab Root Token"
  category = "login"
  url      = "https://vault.hashibank.com/"
  username = "token"
  password = module.primary_vault.root_token
}

module "monitoring" {
  source = "./modules/monitoring"

  ca_cert_pem          = data.local_file.root_ca_cert.content
  prometheus_namespace = module.namespaces.prometheus_namespace
  grafana_namespace    = module.namespaces.grafana_namespace
  
  prometheus_helm_version = var.prometheus_helm_version
  grafana_helm_version    = var.grafana_helm_version
  loki_helm_version       = var.loki_helm_version
  promtail_helm_version   = var.promtail_helm_version

  prometheus_helm_values   = local.prometheus_helm_values # Loaded from a file
  grafana_helm_values      = local.grafana_helm_values    # Loaded from a file
  loki_helm_values         = local.loki_helm_values
  promtail_helm_values     = local.promtail_helm_values
  prometheus_scrape_config = local.prometheus_scrape_config # Loaded from a file
  grafana_configmap        = local.grafana_configmap
  grafana_dashboards       = local.grafana_vault_dashboard # Loaded from a file
  grafana_loki_config      = local.grafana_loki_config
  vault_root_token         = local.decoded_root_token
}

# module "neo4j" {
#   source = "./modules/neo4j"

#   neo4j_namespace   = module.namespaces.neo4j_namespace
#   helm_release_name = "neo4j"
#   helm_repository   = "https://helm.neo4j.com/neo4j"
#   helm_chart_name   = "neo4j"
#   helm_values       = local.neo4j_helm_values
# }


# module "ldap_cert" {
#   source = "./modules/cert_creation"

#   ca_private_key_pem = data.local_file.root_ca_key.content
#   ca_cert_pem          = data.local_file.root_ca_cert.content

#   common_name  = var.ldap_common_name
#   dns_names    = var.ldap_dns_names
#   organization = var.organization

#   is_ca_certificate     = false
#   validity_period_hours = 8760
#   cert_file_name        = "ldap.crt"
#   key_file_name         = "ldap.key"
#   save_to_file          = true
# }

# module "ldap" {
#   source         = "./modules/ldap"
#   ldap_namespace = module.namespaces.ldap_namespace

#   # Pass certificate and key data from the ldap_cert module
#   ldap_cert_pem        = module.ldap_cert.cert_pem
#   ldap_private_key_pem = module.ldap_cert.private_key_pem
#   ca_cert_pem          = module.ca_cert.cert_pem

#   # Other manifest content and LDIF data
#   openldap_statefulset = local.openldap_statefulset
#   openldap_service     = local.openldap_service
#   phpldapadmin_service = local.phpldapadmin_service
#   openldap_ingress     = local.openldap_ingress
#   ldap_ldif_data       = local.ldap_ldif_data
# }

# module "gitlab_runner" {
#   source = "./modules/gitlab_runner"

#   namespace     = module.namespaces.gitlab_namespace
#   release_name  = "gitlab-runner"
#   chart_version = "0.70.3" # Specify the GitLab Runner chart version you need

#   runner_registration_token = var.gitlab_runner_token
#   gitlab_runner_helm_values = local.gitlab_runner_helm_values
# }

# # module "cert-manager" {
# #   source = "./modules/cert-manager"
# # }

# module "hostname_service" {
#   source = "./modules/hostnaming-service"

#   namespace = module.namespaces.hostnaming-service_namespace
#   hostname_manifest = local.hostname_manifest
# }