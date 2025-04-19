variable "aws_region" {
  description = "AWS region"
  type = string
}

variable "availability_zones" {
    description = "Availability zone"
    type = list(string)
}

variable "vpc_cidr" {
    description = "CIDR for VPC"
    type = string
}

variable "subnet_cidrs" {
    description = "CIDR for subnet"
    type = list(string)
}

variable "route_cidr" {
    description = "CIDR for route"
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

variable "asg_name" {
    description = "Auto scaling group name"
    type = string
}

variable "domain_name" {
    description = "Root domain name"
    type = string
}

variable "dns_record_name" {
    description = "DNS record"
    type = string
}

variable "s3_name" {
    description = "S3 name"
    type = string
}