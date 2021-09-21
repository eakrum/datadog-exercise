module "rds" {
  source = "../../../modules/aws-rds"

  identifier           = var.identifier
  region               = var.region
  environment          = var.environment
  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family               # DB parameter group
  major_engine_version = var.major_engine_version # DB option group
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  database_name = var.database_name
  username      = var.username

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  create_monitoring_role  = var.create_monitoring_role

  snapshot_identifier = var.snapshot_identifier
  tags                = var.tags
}