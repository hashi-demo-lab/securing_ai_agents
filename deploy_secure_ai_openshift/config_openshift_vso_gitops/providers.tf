
provider "kubernetes" {
  # Configuration options
  host = var.cluster_api_url
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  client_key = base64decode(var.client_key)
  client_certificate = base64decode(var.client_certificate)
}