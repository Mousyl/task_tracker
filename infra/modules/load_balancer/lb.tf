resource "aws_lb" "load_balancer" {
    name = var.lb_name
    internal = false
    load_balancer_type = var.lb_type
    security_groups = [var.security_groups]
    subnets = var.subnets
}

resource "aws_lb_target_group" "lb_target_group" {
    name = var.target_group_name
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
}

resource "aws_lb_listener" "lb_listener" {
    load_balancer_arn = aws_lb.load_balancer.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.lb_target_group.arn
    }
}