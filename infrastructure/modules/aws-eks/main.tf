module "eks" {
  source          = "terraform-aws-modules/eks/aws"

  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  vpc_id          = data.aws_vpc.selected.id
  subnets         = data.aws_subnet_ids.selected.ids

  worker_groups = [
    {
      instance_type = var.instance_type
      asg_max_size  = var.asg_max_size
    }
  ]
}