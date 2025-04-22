output "public_ip" {
    value = aws_eip.app-elastic-ip.public_ip
}

output "instance_id" {
    value = aws_instance.app-project.id
}