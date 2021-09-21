# this must be stored into parameter store before running this module - this will be the rds master password
data "aws_ssm_parameter" "db_password" {
  name       = "rds_password"
}

# Get vpc dynamically 
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.environment]
  }
}

# Get subnets dynamically 
data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = ["${var.environment}-private-*"]
  }
}