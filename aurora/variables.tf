variable "region" {
  type = string
}

variable "aurora_cluster" {
  type = map
}

variable "aurora_instance" {
  type = map
}

variable "db_subnet_group" {
  type = map
}