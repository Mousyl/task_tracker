provider "aws" {
    region = var.aws_region
    shared_credentials_files = ["${path.module}/terraform_aws_key"]
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  subnet_cidrs = var.subnet_cidrs
  availability_zones = var.availability_zones
  route_cidr = var.route_cidr
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/ec2"
  ami_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security.security_group_id]
}

module "s3" {
  source = "./modules/s3"
  s3_name = var.s3_name
}