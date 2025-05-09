variable "project_name" {
  description = "Project name"
  type        = string
}

variable "s3_bucket" {
  type = string
  default = "tfstate-s3-bucket-tasktracker"
}

variable "aws_region" { 
    type = string 
}

variable "dynamodb" {
  type = string
  default = "tfstate-dynamodb-table-task-tracker"
}

variable "iam_user" {
  type = string
  default = "terraform"
}