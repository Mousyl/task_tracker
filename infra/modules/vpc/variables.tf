variable "project_name" {
    description = "Project name"
    type = string
}

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

variable "aws_region" {
  description = "AWS region"
  type = string
}

variable "cluster_name" {
    description = "EKS cluster name"
    type = string
}