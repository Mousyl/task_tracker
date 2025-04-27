# .tfvars variables
variable "project_name" {
    description = "Project name"
    type = string
}

variable "cluster_name" {
    description = "EKS cluster name"
    type = string
}

variable "subnet_ids" {
    description = "Private subnets"
    type = list(string)
}

# default variables
variable "kubernetes_version" {
    description = "Version of Kubernetes"
    type = string
}

variable "desired_size" {
    description = "Desired number of nodes"
    type = number
}

variable "max_size" {
    description = "Max nubmer of nodes"
    type = number
}

variable "min_size" {
    description = "Min number of nodes"
    type = number
}

variable "instance_types" {
    description = "EC2 types for nodes"
    type = list(string)
}
