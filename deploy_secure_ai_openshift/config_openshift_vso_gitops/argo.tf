# get kubernetes secret using datasource 
# data
data "kubernetes_secret" "example" {
  count = var.enable_gitops ? 1 : 0
  metadata {
    name = "argocd-secret"
    namespace = "${var.gitops_namespace}"
  }
}