
provider "kubernetes" {
  # Configuration options
  host = var.host
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  client_key = base64decode(var.client_key)
  client_certificate = base64decode(var.client_certificate)
}


provider "argocd" {
  # Configuration options
  server_addr = var.argocd_server_addr
  username    = var.argocd_username
  password    = data.kubernetes_secret.argocd[0].data["admin.password"]
  insecure    = true
}

provider "github" {
  # Configuration options
  owner = var.github_organization

}
