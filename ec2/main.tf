provider "aws" {
  region     = var.region
  profile = "sandbox-prof"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}