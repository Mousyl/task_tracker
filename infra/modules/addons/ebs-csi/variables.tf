variable "release_name" {
  description = "Helm release name"
  type = string
  default = "aws-ebs-csi-driver"
}

variable "repo" {
  description = "Helm release repository"
  type = string
  default = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
}

variable "chart_version" {
  description = "Version of the EBS CSI driver Helm chart"
  type        = string
}

variable "namespace" {
  description = "Namespace for driver installation"
  type = string
  default = "kube-system"
}

variable "aws_region" {
  type = string
}

variable "service_account_name" {
  type = string
  default = "ebs-csi-controller-sa"
}

variable "ebs_csi_role_arn" {
  type = string

}