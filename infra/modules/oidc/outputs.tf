output "oicd_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "oicd_url" {
  value = aws_iam_openid_connect_provider.eks_oidc.url
}