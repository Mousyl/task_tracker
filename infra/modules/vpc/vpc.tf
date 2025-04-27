resource "aws_vpc" "root" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.project_name}-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.root.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = values(aws_subnet.public)[0].id

  tags = {
    Name = "${var.project_name}-nat"
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets
  vpc_id = aws_vpc.root.id
  cidr_block = each.value
  availability_zone = "${var.aws_region}${each.key}"
    
  tags = {
      Name = "${var.project_name}-public-${each.key}"
      "kubernetes.io/role/elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets
  vpc_id = aws_vpc.root.id
  cidr_block = each.value
  availability_zone = "${var.aws_region}${each.key}"

  tags = {
    Name = "${var.project_name}-private-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.root.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public
    subnet_id = each.value.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.root.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
    for_each = aws_subnet.private
    subnet_id = each.value.id
    route_table_id = aws_route_table.private.id
}