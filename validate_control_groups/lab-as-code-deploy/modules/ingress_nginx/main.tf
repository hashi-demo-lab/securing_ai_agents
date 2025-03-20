resource "helm_release" "ingress_nginx" {
  name       = var.helm_release_name
  repository = var.helm_repository
  chart      = var.helm_chart_name #"${path.module}/ingress-nginx-4.12.0.tgz" 
  namespace  = var.ingress_namespace # Set dynamically from input variable

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = true
  }
}

resource "kubernetes_secret_v1" "ingress_ca" {
  metadata {
    name      = "ingress-ca"
    namespace = var.ingress_namespace
  }
  data = {
    "ca.crt" = var.ca_cert_pem
  }
  type = "Opaque"
}
