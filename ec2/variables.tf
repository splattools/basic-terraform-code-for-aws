variable "region" {
  type        = string
}

variable "ec2_instances" {
  type = map(object({
    instance_type          = string
    ami                    = string
    key_name               = string
    subnet_name              = string
    vpc_security_group_names = list(string)
    tags                   = map(string)
    user_data              = string
  }))
}