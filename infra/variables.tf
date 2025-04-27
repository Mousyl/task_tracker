# general 
variable "aws_region" {
  description = "AWS region"
  type = string
}

variable "project_name" {
    description = "Project name"
    type = string
}

variable "cluster_name" {
    description = "EKS cluster name"
    type = string
}

variable "db_name" {
    description = "Postgres db name"
    type = string
}

# /db module
variable "db_user" {
    description = "Postgres db user"
    type = string
}

variable "db_password" {
    description = "Postgres db password"
    type = string
}

variable "db_host" {
    description = "Postgres host"
    type = string
}

variable "db_port" {
    description = "Postgres port"
    type = string
}

# /app module
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

# /eks module
variable "kubernetes_version" {
    description = "Version of Kubernetes"
    type = string
    default = "1.29"
}

variable "desired_size" {
    description = "Desired number of nodes"
    type = number
    default = 2
}

variable "max_size" {
    description = "Max nubmer of nodes"
    type = number
    default = 3
}

variable "min_size" {
    description = "Min number of nodes"
    type = number
    default = 1
}

variable "instance_types" {
    description = "EC2 types for nodes"
    type = list(string)
    default = [ "t3.micro" ]
}

# /vpc module
variable "vpc_cidr" {
    description = "CIDR for VPC"
    type = string
}

variable "public_subnets" {
    description = "CIDR of public subnets"
    type = map(string)
}

variable "private_subnets" {
    description = "CIDR of privat subnets"
    type = map(string)
}