variable "ami_id" {
    description = "AMI ID for ec2 instance (Ubuntu)"
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

variable "subnet_id" {
    description = "Subnet ID"
    type = string
}

variable "security_group_ids" {
    description = "Security group ID"
    type = list(string)
}