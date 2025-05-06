output "db_secret" {
  value = kubernetes_secret.db_secret.metadata[0].name
}