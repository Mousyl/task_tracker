# Secrets
resource "kubernetes_secret" "db_secret" {
  metadata {
    name = "db-secret"
    }

  data = {
    DB_NAME = base64encode(var.db_name)
    DB_USER = base64encode(var.db_user)
    DB_PASSWORD = base64encode(var.db_password)
    DB_HOST = base64encode(var.db_host)
    DB_PORT = base64encode(var.db_port)
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
        storage = "1Gi"
      }
    }
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

#Postgres DB deployment and service
resource "kubernetes_deployment" "db" {
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
            name = "init-sql"
            mount_path = "/docker-entrypoint-initdb.d/init.sql"
            sub_path = "init.sql"
          }
        }

        volume {
          name = "postgres-data"
          empty_dir {}
        }

        volume {
          name = "init.sql"
          config_map {
            name = kubernetes_config_map.db_init.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "db" {
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