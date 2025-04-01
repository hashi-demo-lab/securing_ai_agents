# get kubernetes secret using datasource 
data "kubernetes_secret" "argocd" {
  count = var.enable_gitops ? 1 : 0
  metadata {
    name = "openshift-gitops-cluster"
    namespace = "${var.argocd_namespace}"
  }
}

# langflow helm chart
resource "argocd_repository" "langflow_helm" {
  repo = "https://langflow-ai.github.io/langflow-helm-charts"
  name = "langflow"
  type = "helm"
}

# Git repository - demo app
resource "argocd_repository" "demo_langflow" {
  repo = "https://github.com/hashi-demo-lab/demo-langflow-simple-agent.git"
  type = "git"
}


