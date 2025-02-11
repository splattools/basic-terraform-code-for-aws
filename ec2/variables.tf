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

variable "ec2_instances" {
  type = map(object({
    instance_type          = string
    ami                    = string
    key_name              = string
    subnet_name           = string
    vpc_security_group_names = list(string)
    tags                  = map(string)
    user_data             = string
    root_volume_size      = number
    root_volume_type      = string
    root_volume_iops      = optional(number)
    root_volume_throughput = optional(number)
    monitoring           = optional(bool, false)
    disable_api_termination = optional(bool, false)
  }))
  description = "Map of EC2 instance configurations"
}
