resource "aws_vpc" "my-vpc-tf" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "my-vpc-terraform"
    }
}

resource "aws_subnet" "my-public-subnet-tf" {
    count = length(var.availability_zones)
    
    vpc_id = aws_vpc.my-vpc-tf.id
    cidr_block = var.subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true
    
    tags = {
        Name = "my-subnet-terraform"
    }
}

resource "aws_internet_gateway" "my-igw-tf" {
  vpc_id = aws_vpc.my-vpc-tf.id
  tags = {
    Name = "my-igw-terraform"
  }
}

resource "aws_route_table" "my-rt-tf" {
  vpc_id = aws_vpc.my-vpc-tf.id
  tags = {
    Name = "my-rt-terraform"
  }
}

resource "aws_route" "my-route-tf" {
  route_table_id = aws_route_table.my-rt-tf.id
  destination_cidr_block = var.route_cidr
  gateway_id = aws_internet_gateway.my-igw-tf.id
}

resource "aws_route_table_association" "rt-association" {
    count = length(var.availability_zones)
    
    subnet_id = aws_subnet.my-public-subnet-tf[count.index].id
    route_table_id = aws_route_table.my-rt-tf.id
}