# create an ECR repository to hold our docker images - takes in a list of ecr repo names
resource "aws_ecr_repository" "ecr_repo" {
  for_each = toset(var.create_ecr ? var.ecr_names : [])
  name     = each.key
  tags = {
    Terraform = "true"
  }
}