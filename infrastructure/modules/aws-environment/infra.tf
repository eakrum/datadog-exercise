# Provision NAT EIPs outside of the VPC so they are not managed by the VPC module
resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : length(var.private_subnets)
  vpc   = true
  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# create a custom vpc for from public module with specs from variables
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                             = var.environment
  cidr                             = var.vpc_cidr
  enable_dhcp_options              = var.enable_dhcp_options
  dhcp_options_domain_name_servers = var.dhcp_options_domain_name_servers
  azs                              = var.vpc_azs
  private_subnets                  = var.private_subnets
  public_subnets                   = var.public_subnets
  enable_dns_hostnames             = true
  enable_nat_gateway               = true
  single_nat_gateway               = var.single_nat_gateway
  reuse_nat_ips                    = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids              = aws_eip.nat.*.id # <= IPs specified here as input to the module

  public_subnet_tags  = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# create vpc SG's based off custom sg module we created in the modules directory
module "aws-security-groups" {
  source = "../aws-security-groups"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  environment    = var.environment

  # allow public to hit 80/443
  create_external_web_sg = true 

  # allow internal IPs to hit 80/443
  create_internal_web_sg = true

  trusted_networks       = var.trusted_networks


  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}


