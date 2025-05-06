resource "kubernetes_ingress_v1" "ingress_resource" {
  metadata {
    name      = var.ingress_name
    namespace = var.app_namespace
    annotations = {
      "nginx.ingree.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule { 
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = var.project_name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }
}