# RDS OUTPUTS
output "db_instance_address" {
  value = module.db.db_instance_address
}

output "db_instance_arn" {
  value = module.db.db_instance_arn
}

output "db_instance_endpoint" {
  value = module.db.db_instance_endpoint
}

output "db_instance_id" {
  value = module.db.db_instance_id
}