resource "aws_instance" "app-project" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = true

  tags = {
    Name = "task_tracker_ec2"
  }

  user_data = file("${path.module}/userdata.sh")
}

resource "aws_eip" "app-elastic-ip" {
  instance = aws_instance.app-project.id
}