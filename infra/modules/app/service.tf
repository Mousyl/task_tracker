resource "kubernetes_service" "app" {
  metadata {
    name = var.project_name
    namespace = var.app_namespace
  }

  spec {
    selector = {
      app = var.project_name
    }

    port {
      port = var.app_container_port
      target_port = var.app_container_port
    }

    type = "ClusterIP"
  }
}