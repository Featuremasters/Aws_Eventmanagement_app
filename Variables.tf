variable "region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS Account ID"
}

variable "table_name" {
  description = "The DynamoDB table name"
}