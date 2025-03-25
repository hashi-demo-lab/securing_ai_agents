locals {
    vault_secrets_operator = file("${path.module}/vault-secrets-operator.yaml")

    openshift_gitops_operator = file("${path.module}/openshift-gitops-operator.yaml")
}


resource "kubernetes_manifest" "vault_operator" {
  manifest = provider::kubernetes::manifest_decode(local.vault_secrets_operator)
}

# HashiCorp Vault Secrets Operator (VSO)
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vaultsecrets"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["openshift.io/sa.scc.mcs"],
      metadata.0.annotations["openshift.io/sa.scc.supplemental-groups"],
      metadata.0.annotations["openshift.io/sa.scc.uid-range"]
    ]
  }

}


# Red Hat OpenShift GitOps Operator
resource "kubernetes_manifest" "gitops_operator" {
  manifest = provider::kubernetes::manifest_decode(local.openshift_gitops_operator)
}

resource "kubernetes_namespace" "gitops_operator" {
  metadata {
    name = "openshift-gitops-operator"
  }

  lifecycle {
    ignore_changes = [
      metadata.0.annotations["openshift.io/sa.scc.mcs"],
      metadata.0.annotations["openshift.io/sa.scc.supplemental-groups"],
      metadata.0.annotations["openshift.io/sa.scc.uid-range"]
    ]
  }

}