region = "ap-northeast-1"

security_group = {
  sg001 = {
    name        = "ec2-sg"
    description = "ec2 security group"
    vpc_name    = "my-vpc"
    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    tags = {
      Name        = "ec2-sg"
      Environment = "dev"
    }
  },
  sg002 = {
    name        = "alb-sg"
    description = "alb security group"
    vpc_name    = "my-vpc"
    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    tags = {
      Name        = "alb-sg"
      Environment = "dev"
    }
  },
  sg003 = {
    name        = "vpce-sg"
    description = "vpce security group"
    vpc_name    = "my-vpc"
    ingress = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    tags = {
      Name        = "vpce-sg"
      Environment = "dev"
    }
  },
  sg004 = {
    name        = "rds-sg"
    description = "rds security group"
    vpc_name    = "my-vpc"
    ingress = [
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    tags = {
      Name        = "rds-sg"
      Environment = "dev"
    }
  },
}