variable "project_name" {
    description = "Project name"
    type = string
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "allowed_ssh_cidr_blocks" {
    description = "List of sidr blocks allowed to ssh into nodes"
    type = list(string)
    default = []
}