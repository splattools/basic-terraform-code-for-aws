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

variable "cluster" {
  type = object({
    name                = string
    capacity_providers  = optional(list(string), ["FARGATE", "FARGATE_SPOT"])
    container_insights = optional(bool, false)
    tags               = map(string)
  })
  description = "ECS cluster configuration"
}

variable "task_definition" {
  type = object({
    family                = string
    network_mode         = optional(string, "awsvpc")
    requires_compatibilities = optional(list(string), ["FARGATE"])
    cpu                  = string
    memory               = string
    execution_role_name  = string
    task_role_name      = optional(string)
    containers = list(object({
      name               = string
      image              = string
      cpu                = number
      memory             = number
      essential          = bool
      port_mappings = optional(list(object({
        container_port   = number
        host_port       = optional(number)
        protocol        = optional(string, "tcp")
      })))
      environment = optional(list(object({
        name  = string
        value = string
      })))
      secrets = optional(list(object({
        name      = string
        valueFrom = string
      })))
      mount_points = optional(list(object({
        sourceVolume  = string
        containerPath = string
        readOnly     = optional(bool, false)
      })))
      log_configuration = optional(object({
        logDriver = string
        options   = map(string)
      }))
    }))
    volumes = optional(list(object({
      name = string
      efs_volume_configuration = optional(object({
        file_system_id = string
        root_directory = optional(string, "/")
      }))
    })))
    tags = map(string)
  })
  description = "ECS task definition configuration"
}

variable "service" {
  type = object({
    name                    = string
    desired_count          = number
    launch_type            = optional(string, "FARGATE")
    force_new_deployment   = optional(bool, true)
    enable_execute_command = optional(bool, false)
    deployment_configuration = optional(object({
      maximum_percent         = optional(number, 200)
      minimum_healthy_percent = optional(number, 100)
      deployment_circuit_breaker = optional(object({
        enable   = bool
        rollback = bool
      }))
    }))
    network_configuration = object({
      vpc_name           = string
      subnet_names       = list(string)
      security_group_names = list(string)
      assign_public_ip  = optional(bool, false)
    })
    load_balancer = optional(object({
      target_group_name = string
      container_name    = string
      container_port    = number
    }))
    service_registries = optional(object({
      registry_arn = string
      port         = optional(number)
    }))
    tags = map(string)
  })
  description = "ECS service configuration"
}
