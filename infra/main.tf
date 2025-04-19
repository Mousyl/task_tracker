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

module "load_balancer" {
  source = "./modules/load_balancer"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids
  security_groups = module.security.security_group_id
  lb_name = var.lb_name
  lb_type = var.lb_type
  target_group_name = var.target_group_name
}

module "ec2" {
  source = "./modules/ec2"
  launch_template_name = var.launch_template_name
  launch_template_ami = var.launch_template_ami
  instance_type = var.instance_type
  key_name = var.key_name
  security_group_id = module.security.security_group_id
  asg_name = var.asg_name
  subnets = module.vpc.public_subnet_ids
  target_group_arn = module.load_balancer.target_group_arn
}

# module "dns" {
#  source = "./modules/dns"
#  domain_name = var.domain_name
#  dns_record_name = var.dns_record_name
#  lb_dns_name = module.load_balancer.lb_dns
#  lb_zone_id = module.load_balancer.lb_zone
#  load_balancer_arn = module.load_balancer.load_balancer_arn
#  target_group_arn = module.load_balancer.target_group_arn
#}

module "s3" {
    source = "./modules/s3"
    s3_name = var.s3_name
}