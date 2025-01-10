provider "aws" {
  region  = "ap-northeast-1"
  profile = "sandbox-prof"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}