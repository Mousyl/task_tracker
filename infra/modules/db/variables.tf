variable "db_name" {
  description = "Postgres db name"
  type        = string
}

variable "db_user" {
  description = "Postgres db user"
  type        = string
}

variable "db_password" {
  description = "Postgres db password"
  type        = string
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = string
}

variable "storage_class_name" {
  type = string
}