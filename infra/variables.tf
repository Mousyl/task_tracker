# general 
variable "aws_region" { type = string }
variable "allowed_ssh_cidr_blocks" { type = list(string) }
variable "project_name" { type = string }
variable "cluster_name" { type = string }

# /vpc module
variable "vpc_cidr" { type = string }
variable "public_subnets" { type = map(string) }
variable "private_subnets" { type = map(string) }

# /eks module
variable "kubernetes_version" { type = string }
variable "desired_size" { type = number }
variable "max_size" { type = number }
variable "min_size" { type = number }
variable "instance_types" { type = list(string) }

# /db module
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_password" { type = string }
variable "db_host" { type = string }
variable "db_port" { type = string }

# /app module
variable "replicas" { type = number }
variable "app_image" { type = string }
variable "app_container_port" { type = number }
variable "app_host" { type = string }