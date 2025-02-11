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

variable "vpc" {
  type = object({
    cidr_block          = string
    enable_dns_support  = bool
    enable_dns_hostnames = bool
    tags                = map(string)
  })
}

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    tags              = map(string)
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    tags              = map(string)
  }))
}

variable "public_route_table" {
  type = object({
    tags = map(string)
  })
}

variable "private_route_table" {
    type = object({
    tags = map(string)
  })
}

variable "internet_gateway" {
  type = object({
    tags = map(string)
  })
}
