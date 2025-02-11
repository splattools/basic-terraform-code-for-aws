terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "s3/terraform.tfstate"
    region = "ap-northeast-1"
    profile = "sandbox-prof"
    encrypt = true
  }
}

provider "aws" {
  region  = var.region
  profile = "sandbox-prof"
}
