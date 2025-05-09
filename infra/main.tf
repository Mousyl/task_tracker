module "vpc" {
  source          = "./modules/vpc"
  aws_region      = var.aws_region
  project_name    = var.project_name
  cluster_name    = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source                  = "./modules/security"
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  allowed_ssh_cidr_blocks = var.allowed_ssh_cidr_blocks
}

module "eks_roles" {
  source       = "./modules/iam/eks_roles"
  project_name = var.project_name
}

module "eks" {
  source               = "./modules/eks"
  project_name         = var.project_name
  cluster_name         = var.cluster_name
  kubernetes_version   = var.kubernetes_version
  subnet_ids           = module.vpc.private_subnet_ids
  instance_types       = var.instance_types
  desired_size         = var.desired_size
  min_size             = var.min_size
  max_size             = var.max_size
  eks_cluster_role_arn = module.eks_roles.eks_cluster_role_arn
  eks_nodes_role_arn   = module.eks_roles.eks_nodes_role_arn

  depends_on = [
    module.vpc,
    module.security,
    module.eks_roles
  ]
}

module "oidc" {
  source       = "./modules/oidc"
  cluster_name = var.cluster_name

  depends_on = [module.eks]
}

module "irsa_roles" {
  source            = "./modules/iam/irsa_roles"
  project_name      = var.project_name
  oidc_provider_arn = module.oidc.oidc_arn
  oidc_provider_url = module.oidc.oidc_url

  depends_on = [module.oidc]
}

module "jenkins_role" {
  source = "./modules/iam/jenkins_roles"
  project_name = var.project_name
  aws_region = var.aws_region
}

module "ebs_csi" {
  source           = "./modules/addons/ebs-csi"
  ebs_csi_role_arn = module.irsa_roles.ebs_csi_role_arn

  depends_on = [
    module.eks,
    module.irsa_roles
  ]
}

module "ingress_nginx" {
  source = "./modules/addons/nginx"

  depends_on = [module.eks]
}

module "db" {
  source             = "./modules/db"
  db_name            = var.db_name
  db_user            = var.db_user
  db_password        = var.db_password
  db_host            = var.db_host
  db_port            = var.db_port
  storage_class_name = module.ebs_csi.storage_class_name

  depends_on = [module.ebs_csi]
}

module "app" {
  source             = "./modules/app"
  project_name       = var.project_name
  app_image          = var.app_image
  app_container_port = var.app_container_port
  replicas           = var.replicas
  db_secret          = module.db.db_secret
  app_namespace      = "default"
  ingress_name       = "app-ingress"
  service_name       = "app-service"
  service_port       = 80
  host               = var.app_host

  depends_on = [
    module.db,
    module.ingress_nginx
  ]
}

terraform {
  backend "s3" {
    bucket = "tfstate-s3-bucket-tasktracker"
    key = "tasktracker/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "tfstate-dynamodb-table-task-tracker"
    encrypt = true
  }
}