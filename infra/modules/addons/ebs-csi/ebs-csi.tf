resource "kubernetes_service_account" "ebs_csi" {
  metadata {
    name      = var.service_account_name
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
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = var.service_account_name
  }

} 

# Storage Class for EBS volumes
resource "kubernetes_storage_class" "ebs-gp2" {
  metadata {
    name = "ebs-gp2"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy     = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp2"
    fsType = "ext4"
  }

  depends_on = [ helm_release.ebs_csi_driver ]
}

resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  force = true
}