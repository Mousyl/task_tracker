output "storage_class_name" {
  value = kubernetes_storage_class.ebs-gp2.metadata[0].name
}