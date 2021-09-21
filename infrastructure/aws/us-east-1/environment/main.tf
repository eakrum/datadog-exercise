module "environment" {
  source      = "../../../modules/aws-environment"

  # Common vars
  ## list of AZs to create subnets in
  vpc_azs = var.vpc_azs

  trusted_networks = var.trusted_networks

  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  # CIDRs of subnets
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # If true, one NAT GW will be used for all private IPs
  single_nat_gateway = var.single_nat_gateway

  # if true, will allow 443/80 from 0.0.0.0/0
  allow_public_ingress = var.allow_public_ingress

  # set custom domain servers
  enable_dhcp_options = var.enable_dhcp_options
  
  # ECR variables
  create_ecr          = var.create_ecr
  ecr_names           = var.ecr_names
  public_subnet_tags  = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
}