data "http" "my-ip" {
  url = "http://checkip.amazonaws.com"
}

resource "aws_security_group" "my-sg-tf" {
  vpc_id = var.vpc_id
  tags = {
    Name = "my-sg-terraform"
  }
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ip.response_body)}/32"]
  }
  
  ingress {
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
}