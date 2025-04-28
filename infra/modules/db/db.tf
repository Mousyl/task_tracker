# Secrets
resource "kubernetes_secret" "db_secret" {
  metadata {
    name = "db-secret"
    }

  data = {
    POSTGRES_DB = base64encode(var.db_name)
    POSTGRES_USER = base64encode(var.db_user)
    POSTGRES_PASSWORD = base64encode(var.db_password)
  }
}

# Config Map for db
resource "kubernetes_config_map" "db_init" {
  metadata {
    name = "db-init"
  }
  data = {
    init_sql = file("${path.module}/init.sql")
  }
}

resource "kubernetes_persistent_volume_claim" "db" {
  metadata {
    name = "db-pvc"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = "gp2"
  }
}

#Postgres DB deployment and service
resource "kubernetes_deployment" "db" {
  depends_on = [
    kubernetes_secret.db_secret,
    kubernetes_config_map.db_init,
    kubernetes_persistent_volume_claim.db
  ]

  metadata {
    name = "db"
    labels = {
      app = "db"
    }
  }
  spec {
    replicas = 1
        
    selector {
      match_labels = {
        app = "db"
      }
    }
        
    template {
      metadata {
        labels = {
          app = "db"
        }
      }

      spec {
        volume {
          name = "postgres-data"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.db.metadata[0].name
            }
        }
        volume {
          name = "init-db"
          config_map {
            name = kubernetes_config_map.db_init.metadata[0].name
          }
        }

        container {
          name = "db"
          image = "postgres:latest"
                
          port {
            container_port = 5432
          }
                
          env_from {
            secret_ref {
              name = kubernetes_secret.db_secret.metadata[0].name
            }
          }

          volume_mount {
            name = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name = "init-db"
            mount_path = "/docker-entrypoint-initdb.d"
          }

          liveness_probe {
            exec {
              command = ["pg_isready", "-U", var.db_user]
            }
            initial_delay_seconds = 5
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 3
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", var.db_user]
            }
            initial_delay_seconds = 5
            period_seconds = 5
            timeout_seconds = 3
            failure_threshold = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "db" {
  depends_on = [kubernetes_deployment.db]

  metadata {
    name = "db"
  }

  spec {
    selector = {
      app = "db"
    }

    port {
      port = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}