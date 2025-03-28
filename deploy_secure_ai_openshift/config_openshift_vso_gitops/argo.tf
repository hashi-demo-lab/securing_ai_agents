# get kubernetes secret using datasource 
# data
data "kubernetes_secret" "argocd" {
  count = var.enable_gitops ? 1 : 0
  metadata {
    name = "openshift-gitops-cluster"
    namespace = "${var.gitops_namespace}"
  }
}