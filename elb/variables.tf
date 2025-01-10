variable "region" {
  type        = string
}

variable "load_balancer" {
  type = object({
    name               = string
    internal           = bool
    load_balancer_type = string
    security_group_names = list(string)
    subnet_names = list(string)
    enable_deletion_protection = bool
    enable_cross_zone_load_balancing = bool
    idle_timeout = number
    enable_http2 = bool
    tags = map(string)
  })
}

variable "target_group" {
  type = object({
    name = string
    vpc_name = string
    port = number
    protocol = string
    health_check = object({
      path                = string
      protocol            = string
      port                = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })
    tags = map(string)
  })
}

variable "target_instances" {
  type = map(object({
    instance_name = string
    port          = number
  }))
}