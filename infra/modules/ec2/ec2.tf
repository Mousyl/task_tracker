resource "aws_launch_template" "my-launch-template-tf" {
  name = var.launch_template_name
  image_id = var.launch_template_ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [ var.security_group_id ]

  user_data = base64encode(file("${path.module}/userdata.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-instance"
    }
  }
}

resource "aws_autoscaling_group" "me-asg-tf" {
  name = var.asg_name
  desired_capacity = 3
  max_size = 4
  min_size = 2
  vpc_zone_identifier = var.subnets

  launch_template {
    id = aws_launch_template.my-launch-template-tf.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]
}