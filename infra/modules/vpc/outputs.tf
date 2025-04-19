output "vpc_id" {
  description = "Created VPC ID"
  value = aws_vpc.my-vpc-tf.id
}

output "public_subnet_ids" {
  description = "Public subnet ids"
  value = tolist(aws_subnet.my-public-subnet-tf[*].id)
}