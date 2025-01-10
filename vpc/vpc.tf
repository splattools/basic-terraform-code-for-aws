resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr_block
  tags       = var.vpc.tags
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_dns_support   = var.vpc.enable_dns_support
}

resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.public_route_table.tags
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.internet_gateway.tags
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}


resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.private_route_table.tags
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}
