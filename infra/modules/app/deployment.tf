resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.project_name
    namespace = var.app_namespace
    labels = {
      app = var.project_name
    }
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
          name  = var.project_name
          image = var.app_image

          port {
            container_port = var.app_container_port
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key  = "POSTGRES_DB"
              }
            }
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          env {
            name = "POSTGRES_PORT"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key  = "POSTGRES_PORT"
              }
            }
          }

          env {
            name = "POSTGRES_HOST"
            value_from {
              secret_key_ref {
                name = var.db_secret
                key  = "POSTGRES_HOST"
              }
            }
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = var.app_container_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = var.app_container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }
      }
    }
  }
}