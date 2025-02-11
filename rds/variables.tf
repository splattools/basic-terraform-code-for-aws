variable "region" {
  type        = string
  description = "AWS region"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "environment" {
  type        = string
  description = "Environment name for resource tagging"
}

variable "rds" {
  type = object({
    instance_class               = string
    engine                       = string
    engine_version               = string
    identifier                   = string
    allocated_storage            = number
    max_allocated_storage       = optional(number)
    storage_type                 = string
    storage_encrypted           = optional(bool, true)
    publicly_accessible          = bool
    user                         = string
    password                     = string
    vpc_security_group_names     = list(string)
    multi_az                     = bool
    performance_insights_enabled = bool
    performance_insights_retention_period = optional(number, 7)
    deletion_protection          = bool
    skip_final_snapshot          = bool
    final_snapshot_identifier   = optional(string)
    backup_retention_period     = optional(number, 7)
    backup_window              = optional(string, "03:00-04:00")
    maintenance_window         = optional(string, "Mon:04:00-Mon:05:00")
    auto_minor_version_upgrade = optional(bool, true)
    copy_tags_to_snapshot     = optional(bool, true)
    parameter_group_family    = optional(string)
    parameter_group_parameters = optional(map(string), {})
    tags                         = map(string)
  })
  description = "RDS instance configuration"
}

variable "db_subnet_group" {
  type = object({
    name         = string
    subnet_names = list(string)
    tags         = map(string)
  })
  description = "DB subnet group configuration"
}
