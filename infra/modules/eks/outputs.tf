output "cluster_name" {
    value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
    value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca" {
    value = aws_eks_cluster.eks_cluster.certificate_authority
}