variable "project_name" {
  description = "Project name"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "app_image" {
  description = "Application image"
  type        = string
}

variable "app_container_port" {
  description = "Application container port"
  type        = number
}

variable "db_secret" {
  description = "DB secrets(user, password, etc.)"
  type        = string
}

variable "app_namespace" {
  description = "App namespace"
  type        = string
}

variable "ingress_name" {
  description = "Ingress resource name"
  type        = string
}

variable "host" {
  type = string
}

variable "service_name" {
  type = string
}

variable "service_port" {
  type = number
}