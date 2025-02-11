resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc.cidr_block
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_dns_support   = var.vpc.enable_dns_support
  instance_tenancy     = "default"
  
  tags = merge(
    var.vpc.tags,
    {
      Name        = "${var.project}-${var.environment}-vpc"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    each.value.tags,
    {
      Name = "${var.project}-${var.environment}-public-subnet-${each.key}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Type        = "public"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  
  tags = merge(
    var.public_route_table.tags,
    {
      Name        = "${var.project}-${var.environment}-public-rt"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Type        = "public"
    }
  )
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  
  tags = merge(
    var.internet_gateway.tags,
    {
      Name        = "${var.project}-${var.environment}-igw"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}


resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    each.value.tags,
    {
      Name = "${var.project}-${var.environment}-private-subnet-${each.key}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Type        = "private"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  
  tags = merge(
    var.private_route_table.tags,
    {
      Name        = "${var.project}-${var.environment}-private-rt"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
      Type        = "private"
    }
  )
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}
