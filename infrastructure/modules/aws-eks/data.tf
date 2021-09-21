data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
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