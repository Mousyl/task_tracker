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