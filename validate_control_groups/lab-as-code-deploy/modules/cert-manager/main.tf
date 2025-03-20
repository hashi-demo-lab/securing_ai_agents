resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "hashibank"
  version    = "v1.11.0"

  # Create the namespace if it doesn't already exist.
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }

  # Optional: Wait until all resources are ready.
  wait    = true
  timeout = 600
}
