# IAM role for eks cluster
resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.project_name}-eks-cluster-role"
    assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
}

data "aws_iam_policy_document" "eks_cluster_assume_role" {
    statement {
      actions = [ "sts:AssumeRole" ]
      principals {
        type = "Service"
        identifiers = [ "eks.amazonaws.com" ]
      }
    }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attach" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_eks_cluster" "eks_cluster" {
    name = var.cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn
    version = var.kubernetes_version

    vpc_config {
      subnet_ids = var.subnet_ids
    }

    tags = {
      Name = "${var.project_name}-eks"
    }
}

# IAM role for eks nodes
resource "aws_iam_role" "eks_nodes_role" {
    name = "${var.project_name}-eks-nodes-role"
    assume_role_policy = data.aws_iam_policy_document.eks_nodes_assume_role.json
}

data "aws_iam_policy_document" "eks_nodes_assume_role" {
    statement {
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["ec2.amazonaws.com"] 
      }
    }
}

resource "aws_iam_role_policy_attachment" "eks_nodes_role_attach" {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ])
    role = aws_iam_role.eks_nodes_role.name
    policy_arn = each.key
}

# Managed node group
resource "aws_eks_node_group" "default" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = "${var.project_name}-nodes"
    node_role_arn = aws_iam_role.eks_nodes_role.arn
    subnet_ids = var.subnet_ids

    scaling_config {
      desired_size = var.desired_size
      max_size = var.max_size
      min_size = var.min_size
    }

    instance_types = var.instance_types

    tags = {
      Name = "${var.project_name}-node-group"
    }

}