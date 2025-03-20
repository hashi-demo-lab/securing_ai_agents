resource "helm_release" "neo4j" {
  name       = var.helm_release_name
  repository = var.helm_repository
  chart      = var.helm_chart_name
  namespace  = kubernetes_namespace.neo4j.metadata.0.name

  values = [
    var.helm_values
  ]
}
