terraform {
  backend "s3" {
    bucket = "eakrum-datadog-terraform-state"
    key    = "us-east-1/development/datadog-eks-1.tfstate"
    region = "us-east-1"
    dynamodb_table = "aws-terraform-state-lock"
  }
}