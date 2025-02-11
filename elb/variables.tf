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

variable "load_balancer" {
  type = object({
    name                             = string
    internal                         = bool
    load_balancer_type               = string
    security_group_names             = list(string)
    subnet_names                     = list(string)
    enable_deletion_protection       = bool
    enable_cross_zone_load_balancing = optional(bool, true)
    idle_timeout                     = optional(number, 60)
    enable_http2                     = optional(bool, true)
    drop_invalid_header_fields       = optional(bool, false)
    preserve_host_header            = optional(bool, false)
    desync_mitigation_mode          = optional(string, "defensive")
    access_logs = optional(object({
      bucket  = string
      prefix  = optional(string)
      enabled = optional(bool, true)
    }))
    https_listener = optional(object({
      port               = optional(number, 443)
      certificate_arn    = string
      ssl_policy        = optional(string, "ELBSecurityPolicy-2016-08")
      default_action     = optional(string, "forward")
    }))
    tags = map(string)
  })
  description = "Application Load Balancer configuration"
}

variable "target_group" {
  type = object({
    name     = string
    vpc_name = string
    port     = number
    protocol = string
    target_type = optional(string, "instance")
    deregistration_delay = optional(number, 300)
    slow_start          = optional(number, 0)
    proxy_protocol_v2   = optional(bool, false)
    stickiness = optional(object({
      enabled         = bool
      type           = string
      cookie_duration = optional(number, 86400)
    }))
    health_check = object({
      path                = string
      protocol            = string
      port                = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
      matcher             = optional(string, "200")
    })
    tags = map(string)
  })
  description = "Target group configuration"
}

variable "target_instances" {
  type = map(object({
    instance_name = string
    port         = number
    weight       = optional(number, 100)
  }))
  description = "Map of target instances configuration"
}
