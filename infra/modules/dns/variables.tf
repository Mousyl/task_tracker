variable "domain_name" {
    description = "Root domain name"
    type = string
}

variable "dns_record_name" {
    description = "DNS record"
    type = string
}

variable "lb_dns_name" {
    description = "Load Balancer DNS name"
    type = string
}

variable "lb_zone_id" {
    description = "Load Balancer Zone ID"
    type = string
}

variable "load_balancer_arn" {
    description = "Load Balancer ARN"
    type = string
}

variable "target_group_arn" {
    description = "Target group ARN"
    type = string
}