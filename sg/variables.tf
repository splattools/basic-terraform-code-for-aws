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

variable "security_group" {
  type = map(object({
    name        = string
    description = string
    vpc_name    = string
    ingress = list(object({
      description     = string
      from_port      = number
      to_port        = number
      protocol       = string
      cidr_blocks    = optional(list(string))
      security_groups = optional(list(string))
      self           = optional(bool, false)
    }))
    egress = list(object({
      description     = string
      from_port      = number
      to_port        = number
      protocol       = string
      cidr_blocks    = optional(list(string))
      security_groups = optional(list(string))
      self           = optional(bool, false)
    }))
    timeouts = optional(object({
      create = optional(string, "10m")
      delete = optional(string, "10m")
    }))
    revoke_rules_on_delete = optional(bool, false)
    tags                   = map(string)
  }))
  description = "Map of security group configurations"
}
