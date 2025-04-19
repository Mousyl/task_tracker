resource "aws_route53_zone" "my_nginx" {
    name = var.domain_name
}

resource "aws_acm_certificate" "my_nginx_cert" {
    domain_name = var.domain_name
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route53_record" "cert_validation" {
    for_each = {
      for dvo in aws_acm_certificate.my_nginx_cert.domain_validation_options : 
      dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
      }
    }
    allow_overwrite = true
    name = each.value.name
    records = [ each.value.record ]
    ttl = 60
    type = each.value.type
    zone_id = aws_route53_zone.my_nginx.zone_id
}

resource "aws_acm_certificate_validation" "my_nginx_cert_validation" {
    certificate_arn = aws_acm_certificate.my_nginx_cert.arn
    validation_record_fqdns = [ for record in aws_route53_record.cert_validation : record.fqdn ]
}

resource "aws_route53_record" "alias_record" {
    zone_id = aws_route53_zone.my_nginx.zone_id
    name = var.dns_record_name
    type = "A"

    alias {
        name = var.lb_dns_name
        zone_id = var.lb_zone_id
        evaluate_target_health = true
    }
}

resource "aws_lb_listener" "https" {
    load_balancer_arn = var.load_balancer_arn
    port = 443
    protocol = "HTTPS"
    certificate_arn = aws_acm_certificate_validation.my_nginx_cert_validation.certificate_arn
    default_action {
      type = "forward"
      target_group_arn = var.target_group_arn
    }
}