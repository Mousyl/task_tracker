variable "launch_template_name" {
    description = "Launch template name"
    type = string
}

variable "launch_template_ami" {
    description = "Launch template ami ID (Ubuntu for eu-north-1)"
    type = string
}

variable "instance_type" {
    description = "Instance type"
    type = string
}

variable "key_name" {
    description = "Key pair name for Terraform"
    type = string
}

variable "security_group_id" {
    description = "Security group ID"
    type = string
}

variable "asg_name" {
    description = "Auto scaling group name"
    type = string
}

variable "subnets" {
    description = "Subnets list"
    type = list(string)
}

variable "target_group_arn" {
    description = "Target Group ARN"
    type = string
}