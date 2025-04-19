variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "subnets" {
    description = "Public subnets"
    type = list(string)
}

variable "security_groups" {
    description = "Security group ID"
    type = string
}

variable "lb_name" {
    description = "Load Balancer name"
    type = string
}

variable "lb_type" {
    description = "Load Balancer type"
    type = string
}

variable "target_group_name" {
    description = "Target group name"
    type = string
}