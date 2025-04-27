variable "project_name" {
    description = "Project name"
    type = string
}

variable "replicas" {
    description = "Number of replicas"
    type = number
}

variable "app_image" {
    description = "Application image"
    type = string
}

variable "app_container_port" {
    description = "Application container port"
    type = number
}

variable "db_secret" {
    description = "DB secrets(user, password, etc.)"
    type = string
}