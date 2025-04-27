# App deployment and service
resource "kubernetes_deployment" "app" {
  metadata {
    name = var.project_name
  }

  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = var.project_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.project_name
        }
      }
      spec {
        container {
          name = var.project_name
          image = var.app_image
          
          port {
            container_port = var.app_container_port
          }

          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key = "DB_NAME"
              }
            }
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key = "DB_USER"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key = "DB_PASSWORD"
              }
            }
          }

          env {
            name = "DB_HOST"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key = "DB_HOST"
              }
            }
          }

          env {
            name = "DB_PORT"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key = "DB_PORT"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = var.project_name
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

