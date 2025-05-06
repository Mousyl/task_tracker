# Cluster creation
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = "${var.project_name}-eks"
  }
}

# Managed node group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = var.eks_nodes_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  tags = {
    Name = "${var.project_name}-node-group"
  }
}