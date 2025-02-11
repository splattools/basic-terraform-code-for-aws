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

variable "gateway_endpoints" {
  type = map(object({
    vpc_name          = string
    service_name      = string
    route_table_names = list(string)
    auto_accept       = optional(bool, true)
    policy           = optional(string)
    tags             = map(string)
  }))
  description = "Map of Gateway VPC endpoint configurations"
}

variable "interface_endpoints" {
  type = map(object({
    vpc_name             = string
    service_name         = string
    security_group_names = list(string)
    subnet_names         = list(string)
    private_dns_enabled  = optional(bool, true)
    auto_accept         = optional(bool, true)
    policy             = optional(string)
    ip_address_type    = optional(string, "ipv4")
    dns_options = optional(object({
      dns_record_ip_type = optional(string, "ipv4")
    }))
    timeouts = optional(object({
      create = optional(string, "10m")
      update = optional(string, "10m")
      delete = optional(string, "10m")
    }))
    tags = map(string)
  }))
  description = "Map of Interface VPC endpoint configurations"
}
