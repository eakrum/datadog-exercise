terraform {
  backend "s3" {
    bucket = "eakrum-datadog-terraform-state"
    key    = "us-east-1/development/rds.tfstate"
    region = "us-east-1"
    dynamodb_table = "aws-terraform-state-lock"
  }
}