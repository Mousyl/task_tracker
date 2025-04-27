module "vpc" {
  source = "./modules/vpc"
  aws_region = var.aws_region
  project_name = var.project_name
  cluster_name = var.cluster_name
  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source = "./modules/security"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
}

module "eks" {
  source = "./modules/eks"
  project_name = var.project_name
  cluster_name = var.cluster_name
  kubernetes_version = var.kubernetes_version
  subnet_ids = module.vpc.private_subnet_ids
  instance_types = var.instance_types
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size

  depends_on = [ 
    module.vpc,
    module.security
   ]
}

module "db" {
  source = "./modules/db"
  db_name = var.db_name
  db_user = var.db_user
  db_password = var.db_password
  db_host = var.db_host
  db_port = var.db_port

  depends_on = [ module.eks ]
}

module "app" {
  source = "./modules/app"
  project_name = var.project_name
  app_image = var.app_image
  app_container_port = var.app_container_port
  replicas = var.replicas
  db_secret = module.db.db_secret

  depends_on = [ module.db ]
}

module "webserver" {
  source = "./modules/webserver"

  depends_on = [ module.app ]
}