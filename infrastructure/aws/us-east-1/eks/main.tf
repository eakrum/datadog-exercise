module "datadog-eks" {
  source = "../../../modules/aws-eks"

  environment = var.environment
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name

}