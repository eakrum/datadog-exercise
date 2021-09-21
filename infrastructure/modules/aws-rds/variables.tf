variable "region" {}
variable "environment" {}
variable "identifier" {}
variable "engine" {}
variable "engine_version" {}
variable "family" {}
variable "major_engine_version" {}
variable "instance_class" {}
variable "allocated_storage" {}
variable "max_allocated_storage" {}
variable "database_name" {}
variable "username" {
  default = "postgres"
}
variable "backup_retention_period" {}
variable "deletion_protection" {}
variable "create_monitoring_role" {}
variable "tags" {
  default = {}
}
variable "snapshot_identifier" {}
