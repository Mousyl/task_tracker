resource "kubernetes_config_map" "nginx" {
  metadata {
    name = var.webserver_name
  }
  data = {
    nginx= file("${path.module}/nginx.conf")
  }
}

# Nginx deployment and service
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = var.webserver_name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.webserver_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.webserver_name
        }
      }

      spec {
        volume {
          name = "${var.webserver_name}-conf"
          config_map {
            name = kubernetes_config_map.nginx.metadata[0].name
          }
        }

        container {
          name = var.webserver_name
          image = var.image

          port {
            container_port = var.port
          }

          volume_mount {
            name = "${var.webserver_name}-conf"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path = "nginx.conf"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = var.webserver_name
  }

  spec {
    selector = {
      app = var.webserver_name
    }

    port {
      port = var.port
    }

    type = "LoadBalancer"
  }
}