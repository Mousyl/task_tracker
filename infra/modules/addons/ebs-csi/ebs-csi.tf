resource "kubernetes_service_account" "ebs_csi" {
  metadata {
    name = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.ebs_csi_role_arn
    }
  }
}

resource "helm_release" "ebs_csi_driver" {
  name       = var.release_name
  repository = var.repo
  chart      = "aws-ebs-csi-driver"
  version    = var.chart_version
  namespace  = var.namespace

  set {
    name = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name = "controller.serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name = "region"
    value = var.aws_region
  }
} 