# use a public module to create the postgres SG in the selected VPC
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${var.identifier}-sg"
  description = "Security group for Database ${var.identifier}"
  vpc_id      = data.aws_vpc.selected.id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.selected.cidr_block
    }
  ]

  tags = var.tags
}

# use a public module to create the actual RDS instance
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.identifier

  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family               # DB parameter group
  major_engine_version = var.major_engine_version # DB option group
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true

  name                   = var.database_name
  username               = var.username
  password               = data.aws_ssm_parameter.db_password.value
  port                   = 5432

  multi_az               = true
  subnet_ids             = data.aws_subnet_ids.selected.ids
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = var.deletion_protection

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = var.create_monitoring_role
  monitoring_role_name                  = "${var.identifier}-monitoring-role"
  monitoring_interval                   = 60

  snapshot_identifier = var.snapshot_identifier

  tags = var.tags
}

