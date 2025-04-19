output "s3_name" {
    value = aws_s3_bucket.project_s3.id
}

output "s3_arn" {
    value = aws_s3_bucket.project_s3.arn
}

output "s3_url" {
    value = "s3://${aws_s3_bucket.project_s3.id}"
}