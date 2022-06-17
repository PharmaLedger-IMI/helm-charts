#
# "Secrets Store CSI Driver"
#
# Common:         https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html
# Common:         https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html
# Helm Chart:         https://github.com/kubernetes-sigs/secrets-store-csi-driver/tree/v1.1.2/charts/secrets-store-csi-driver
# Helm Chart values:  https://github.com/kubernetes-sigs/secrets-store-csi-driver/blob/v1.1.2/charts/secrets-store-csi-driver/values.yaml
#
resource "helm_release" "csi_secrets_store_driver" {
  name      = "csi-secrets-store-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.1.2"
}

#
# "CSI Secrets Store Provider AWS" - Requires the driver to be installed first
#
# Common:         https://github.com/aws/secrets-store-csi-driver-provider-aws
# Helm Chart:         https://github.com/aws/eks-charts/tree/v0.0.85/stable/csi-secrets-store-provider-aws
# Helm Chart values:  https://github.com/aws/eks-charts/blob/v0.0.85/stable/csi-secrets-store-provider-aws/values.yaml
#
resource "helm_release" "csi_secrets_store_provider_aws" {
  depends_on = [
    helm_release.csi_secrets_store_driver
  ]
  name      = "csi-secrets-store-provider-aws"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "csi-secrets-store-provider-aws"
  version    = "0.0.2"

  # Do not install the Driver as we install it on our own
  set {
    name  = "secrets-store-csi-driver.install"
    value = false
  }
}