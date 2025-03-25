locals {
    vault_secrets_operator = file("${path.module}/manifests/vault-secrets-operator.yaml")

    openshift_gitops_operator = file("${path.module}/manifests/openshift-gitops-operator.yaml")
}


# HashiCorp Vault Secrets Operator (VSO)
resource "kubernetes_namespace" "vault" {
  count = var.enable_vso ? 1 : 0

  metadata {
    name = var.vso_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["openshift.io/sa.scc.mcs"],
      metadata.0.annotations["openshift.io/sa.scc.supplemental-groups"],
      metadata.0.annotations["openshift.io/sa.scc.uid-range"]
    ]
  }
}

resource "kubernetes_manifest" "vault-operator" {
  count    = var.enable_vso ? 1 : 0
  manifest = provider::kubernetes::manifest_decode(local.vault_secrets_operator)
}

# Red Hat OpenShift GitOps Operator
resource "kubernetes_namespace" "gitops_operator" {
  count = var.enable_gitops ? 1 : 0

  metadata {
    name = var.gitops_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["openshift.io/sa.scc.mcs"],
      metadata.0.annotations["openshift.io/sa.scc.supplemental-groups"],
      metadata.0.annotations["openshift.io/sa.scc.uid-range"]
    ]
  }
}

resource "kubernetes_manifest" "gitops_operator" {
  count     = var.enable_gitops ? 1 : 0
  depends_on = [ kubernetes_namespace.gitops_operator ]
  manifest  = provider::kubernetes::manifest_decode(local.openshift_gitops_operator)
}