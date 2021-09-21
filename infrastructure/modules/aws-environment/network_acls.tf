data "aws_network_acls" "public" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "association.subnet-id"
    values = module.vpc.public_subnets
  }
}

data "aws_network_acls" "private" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "association.subnet-id"
    values = module.vpc.private_subnets
  }
}

# Allow public ingress if allow_public_ingress is true
resource "aws_network_acl_rule" "allow_public_ingress_443" {
  count          = var.allow_public_ingress && length(var.public_subnets) > 0 ? 1 : 0
  network_acl_id = element(tolist(data.aws_network_acls.public.ids), 0)
  rule_number    = 1
  egress         = false
  protocol       = 6
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "allow_public_ingress_80" {
  count          = var.allow_public_ingress && length(var.public_subnets) > 0 ? 1 : 0
  network_acl_id = element(tolist(data.aws_network_acls.public.ids), 0)
  rule_number    = 2
  egress         = false
  protocol       = 6
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow internet (ephemeral) traffic for private ACL
# Seems to be a bug with aws/TF if the protocol is set to a number instead of string, will always try to recreate
resource "aws_network_acl_rule" "allow_ephemeral_private_ingress" {
  count          = length(var.private_subnets) > 0 ? 1 : 0
  network_acl_id = element(tolist(data.aws_network_acls.private.ids), 0)
  rule_number    = 5
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow private->public + trusted, needed for NAT gateway
resource "aws_network_acl_rule" "allow_trusted_in_public" {
  count          = length(var.public_subnets) > 0 ? length(var.trusted_networks) : 0
  network_acl_id = element(tolist(data.aws_network_acls.public.ids), 0)
  rule_number    = 900 + count.index
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = element(var.trusted_networks, count.index)
  from_port      = 1
  to_port        = 65535
}

# Allow internet outbound
resource "aws_network_acl_rule" "allow_outbound_traffic" {
  count          = length(var.private_subnets) > 0 ? 1 : 0
  network_acl_id = element(tolist(data.aws_network_acls.private.ids), 0)
  rule_number    = 10
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_public_outbound_traffic" {
  count          = length(var.public_subnets) > 0 ? 1 : 0
  network_acl_id = element(tolist(data.aws_network_acls.public.ids), 0)
  rule_number    = 10
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1
  to_port        = 65535
}

# Block public ingress besides web traffic
resource "aws_network_acl_rule" "allow_ephemeral_public_ingress" {
  count          = length(var.public_subnets) > 0 ? 1 : 0
  network_acl_id = element(tolist(data.aws_network_acls.public.ids), 0)
  rule_number    = 5
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "block_public_ingress" {
  count          = length(var.public_subnets) > 0 ? 1 : 0
  network_acl_id = element(tolist(data.aws_network_acls.public.ids), 0)
  rule_number    = 9000
  egress         = false
  protocol       = -1
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1
  to_port        = 65535
}
