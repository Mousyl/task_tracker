output "lb_dns" {
    description = "Load Balancer DNS name"
    value = aws_lb.load_balancer.dns_name
}

output "load_balancer_arn" {
    description = "Load Balancer ARN"
    value = aws_lb.load_balancer.arn
}

output "target_group_arn" {
    description = "Target group ARN"
    value = aws_lb_target_group.lb_target_group.arn
}

output "lb_zone" {
    description = "Load Balancer zone ID"
    value = aws_lb.load_balancer.zone_id
}