variable "region" {
  type        = string
}

variable "gateway_endpoints" {
  type        = map(object({
    vpc_name             = string
    service_name       = string
    route_table_names    = list(string)
    tags               = map(string)
  }))
}

variable "interface_endpoints" {
  type        = map(object({
    vpc_name             = string
    service_name       = string
    security_group_names = list(string)
    subnet_names         = list(string)
    private_dns_enabled = bool
    tags               = map(string)
  }))
}