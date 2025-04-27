data "http" "my-ip" {
  url = "http://checkip.amazonaws.com"
}

resource "aws_security_group" "eks_nodes" {
  name = "${var.project_name}-eks-nodes-security-group"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow all traffic from within the same security group"
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
  
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ip.response_body)}/32"]
  }
  
  ingress {
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-nodes-security-group"
  }
}