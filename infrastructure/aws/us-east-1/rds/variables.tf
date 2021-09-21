variable "identifier" {}
variable "region" {}
variable "environment" {}
variable "engine" {}
variable "engine_version" {}
variable "family" {}               # DB parameter group
variable "major_engine_version" {} # DB option group
variable "instance_class" {}
variable "allocated_storage" {}
variable "max_allocated_storage" {}
variable "database_name" {}
variable "username" {}
variable "backup_retention_period" {}
variable "deletion_protection" {
  default = false
}
variable "create_monitoring_role" {
  default = false
}
variable "snapshot_identifier" {
  default = null
}
variable "tags" {}