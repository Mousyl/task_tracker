data "aws_caller_identity" "current_account" {}

resource "aws_iam_policy" "jenkins" {
  name = "${var.project_name}-jenkins-role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
        Effect = "Allow",
        Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
        ],
        Resource = [
            "arn:aws:s3:::${var.s3_bucket}",
            "arn:aws:s3:::${var.s3_bucket}/*"
        ]
    },
    {
        Effect = "Allow",
        Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem",
            "dynamodb:UpdateItem",
            "dynamodb:Scan"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current_account.account_id}:table/${var.dynamodb}"
    },
    {
        Effect = "Allow",
        Action = [
            "eks:DescribeCluster"
        ],
        Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "jenkins_attach" {
  user = "${var.iam_user}"
  policy_arn = aws_iam_policy.jenkins.arn
}