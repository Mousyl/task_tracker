data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "tls_certificate" "tls" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls.certificates[0].sha1_fingerprint]
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}