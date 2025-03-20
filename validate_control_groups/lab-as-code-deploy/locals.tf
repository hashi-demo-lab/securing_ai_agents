# Load the existing Root CA certificate and key from the "certificates" directory
data "local_file" "root_ca_cert" {
  filename = "${path.root}/../certificates/lab-root-ca.crt"
}

data "local_file" "root_ca_key" {
  filename = "${path.root}/../certificates/lab-root-ca.key"
}

locals {
  vso_helm_values           = file("${path.root}/_helm_charts/vault/values.vso.yaml")
  intialise_vault_script    = file("${path.root}/_scripts/vault/initialise-vault.sh")
  auto_unseal_config_script = file("${path.root}/_scripts/vault/auto-unseal-config.sh")
  openldap_statefulset      = file("${path.root}/_manifests/openldap/statefulset.yaml")
  openldap_service          = file("${path.root}/_manifests/openldap/ldap_service.yaml")
  phpldapadmin_service      = file("${path.root}/_manifests/openldap/phpldapadmin_service.yaml")
  openldap_ingress          = file("${path.root}/_manifests/openldap/ingress.yaml")
  ldap_ldif_data            = file("${path.root}/_manifests/openldap/hashibank.ldif")
  hostname_manifest         = file("${path.root}/_manifests/hostnaming-service/hostname.yaml")
  prometheus_scrape_config  = file("./_helm_charts/prometheus/configmap.yaml")
  prometheus_helm_values    = file("./_helm_charts/prometheus/values.prometheus.yaml")
  grafana_configmap         = file("./_helm_charts/grafana/configmap.yaml")
  grafana_helm_values       = file("./_helm_charts/grafana/values.grafana.yaml")
  grafana_vault_dashboard   = file("./_helm_charts/grafana/vault_dashboard.grafana.json")
  loki_helm_values          = file("./_helm_charts/loki/values.loki.yaml")
  promtail_helm_values      = file("./_helm_charts/promtail/values.promtail.yaml")
  grafana_loki_config       = file("./_helm_charts/grafana/loki_datasource.yaml")
  neo4j_helm_values         = file("./_helm_charts/neo4j/values.neo4j.yaml")
  gitlab_runner_helm_values = file("./_helm_charts/gitlab_runner/values.yaml")
  decoded_root_token        = module.primary_vault.root_token

}

# CA Private Key and Certificate used for signing Vault certificates
# Load file contents for Helm values and script for Vault
# OpenLDAP manifests for deployment and services
# Prometheus Helm chart and ConfigMap for monitoring
# Grafana Helm chart and ConfigMap for dashboards
# Loki Helm chart and ConfigMap for logging
# Helm values for Neo4j deployment
# GitLab Runner Helm chart and ConfigMap for Runner registration