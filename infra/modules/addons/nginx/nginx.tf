resource "helm_release" "ingress_nginx" {
  name       = var.release_name
  repository = var.repo
  chart      = "ingress-nginx"
  namespace  = var.namespace_name
  version    = var.chart_version

  create_namespace = var.create_namespace

  set {
    name  = "controller.service.type"
    value = var.service_type
  }

  set {
    name  = "controller.publishService.enabled"
    value = tostring(var.publish_service_enabled)
  }

  set {
    name  = "controller.scope.enabled"
    value = tostring(var.scoped_enabled)
  }

  set {
    name  = "controller.scope.namespace"
    value = var.scope_namespace
  }
}