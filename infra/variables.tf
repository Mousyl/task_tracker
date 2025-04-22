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

variable "ami_id" {
    description = "AMI ID (Ubuntu for eu-north-1)"
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

variable "s3_name" {
    description = "S3 name"
    type = string
}