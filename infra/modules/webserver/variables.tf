variable "webserver_name" {
    description = "Webserver name"
    type = string
    default = "nginx"
}

variable "image" {
    description = "Nginx image"
    type = string
    default = "nginx:alpine"
}

variable "port" {
    description = "Nginx port"
    type = number
    default = 80
}