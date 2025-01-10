region = "ap-northeast-1"

vpc = {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name        = "my-vpc"
    Environment = "dev"
  }
}

public_subnets = {
  public_subnet1 = {
    cidr_block = "10.0.0.0/20"
    availability_zone = "ap-northeast-1a"
    tags       = {
      Name        = "public1"
      Environment = "dev"
    }
  }
  public_subnet2 = {
    cidr_block = "10.0.128.0/20"
    availability_zone = "ap-northeast-1c"
    tags       = {
      Name        = "public2"
      Environment = "dev"
    }
  }
}

private_subnets = {
  private_subnet1 = {
    cidr_block = "10.0.144.0/20"
    availability_zone = "ap-northeast-1a"
    tags       = {
      Name        = "private1"
      Environment = "dev"
    }
  }
  private_subnet2 = {
    cidr_block = "10.0.16.0/20"
    availability_zone = "ap-northeast-1c"
    tags       = {
      Name        = "private2"
      Environment = "dev"
    }
  }
}

public_route_table = {
    tags = {
      Name        = "public"
      Environment = "dev"
    }
}

private_route_table = {
    tags = {
      Name        = "private"
      Environment = "dev"
    }
  }

internet_gateway = {
  tags = {
    Name        = "igw"
    Environment = "dev"
  }
}