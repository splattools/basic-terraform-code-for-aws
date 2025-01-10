variable "region" {
  type = string
}

variable "rds" {
  type = object({
    instance_class               = string
    engine                       = string
    engine_version               = string
    identifier                   = string
    allocated_storage            = number
    storage_type                 = string
    publicly_accessible          = bool
    user                         = string
    password                     = string
    vpc_security_group_names     = list(string)
    multi_az                     = bool
    performance_insights_enabled = bool
    deletion_protection          = bool
    skip_final_snapshot          = bool
    tags                         = map(string)
  })
}

variable "db_subnet_group" {
  type = object({
    name         = string
    subnet_names = list(string)
    tags         = map(string)
  })
}