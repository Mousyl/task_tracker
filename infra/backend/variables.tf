variable "bucket_name" {
  type = string
  default = "tfstate-s3-bucket-tasktracker"
}

variable "dynamodb_table_name" {
  type = string
  default = "tfstate-dynamodb-table-task-tracker"
}