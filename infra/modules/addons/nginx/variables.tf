variable "release_name" {
    type = string
    default = "ingress-nginx"
}

variable "repo" {
    type = string
    default = "https://kubernetes.github.io/ingress-nginx"
}

variable "chart_version" {
    description = "Version of the Helm chart"
    type        = string
}

variable "namespace_name" {
    type = string
    default = "ingress-nginx"
}

variable "create_namespace" {
    type = bool
    default = true
}

variable "service_type" {
    type = string
    default = "LoadBalancer"
}

variable "publish_service_enabled" {
    type = bool
    default = true
}

variable "scoped_enabled" {
    type = bool
    default = false
}

variable "scope_namespace" {
    type = string
    default = "ingress-nginx"
}