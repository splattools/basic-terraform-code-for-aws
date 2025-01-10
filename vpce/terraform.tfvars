region = "ap-northeast-1"

gateway_endpoints = {
  endpoint001 = {
    vpc_name             = "my-vpc"
    service_name       = "com.amazonaws.ap-northeast-1.s3"
    route_table_names    = ["private","public"]
    tags               = {
      Name = "s3-endpoint"
    }
  }
  # endpoint002 = {
  #   vpc_name             = "my-vpc"
  #   service_name       = "com.amazonaws.ap-northeast-1.dynamodb"
  #   route_table_names    = ["private","public"]
  #   tags               = {
  #     Name = "dynamodb-endpoint"
  #   }
  # }
}


interface_endpoints = {
  endpoint001 = {
    vpc_name             = "my-vpc"
    service_name       = "com.amazonaws.ap-northeast-1.ssm"
    security_group_names = ["vpce-sg"]
    subnet_names         = ["private1", "private2"]
    private_dns_enabled = true
    tags               = {
      Name = "ssm-endpoint"
    }
  }
  endpoint002 = {
    vpc_name             = "my-vpc"
    service_name       = "com.amazonaws.ap-northeast-1.ssmmessages"
    security_group_names = ["vpce-sg"]
    subnet_names         = ["private1", "private2"]
    private_dns_enabled = true
    tags               = {
      Name = "ssmmessages-endpoint"
    }
  }
  endpoint003 = {
    vpc_name             = "my-vpc"
    service_name       = "com.amazonaws.ap-northeast-1.ec2messages"
    security_group_names = ["vpce-sg"]
    subnet_names         = ["private1", "private2"]
    private_dns_enabled = true
    tags               = {
      Name = "ec2messages-endpoint"
    }
  }
}