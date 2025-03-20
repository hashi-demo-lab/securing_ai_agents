resource "helm_release" "gitlab_runner" {
  namespace  = var.namespace

  name       = var.release_name
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"
  version    = var.chart_version
  
  values = [var.gitlab_runner_helm_values]

  set_sensitive {
    name  = "runnerRegistrationToken"
    value = var.runner_registration_token
  }
}