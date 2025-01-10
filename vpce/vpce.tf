data "aws_vpc" "gateway_vpc" {
  for_each = var.gateway_endpoints
  filter {
    name   = "tag:Name"
    values = [each.value.vpc_name]
  }
}

data "aws_vpc" "interface_vpc" {
  for_each = var.interface_endpoints
  filter {
    name   = "tag:Name"
    values = [each.value.vpc_name]
  }
}

data "aws_route_tables" "gateway_route_tables" {
  for_each = var.gateway_endpoints
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.gateway_vpc[each.key].id]
  }
  filter {
    name   = "tag:Name"
    values = each.value.route_table_names
  }
}

data "aws_subnets" "interface_subnets" {
  for_each = var.interface_endpoints
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.interface_vpc[each.key].id]
  }
  filter {
    name   = "tag:Name"
    values = each.value.subnet_names
  }
}

data "aws_security_groups" "interface_security_groups" {
  for_each = var.interface_endpoints
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.interface_vpc[each.key].id]
  }
  filter {
    name   = "tag:Name"
    values = each.value.security_group_names
  }
}

resource "aws_vpc_endpoint" "gateway_endpoint" {
  for_each = var.gateway_endpoints

  vpc_id          = data.aws_vpc.gateway_vpc[each.key].id
  service_name    = each.value.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids = data.aws_route_tables.gateway_route_tables[each.key].ids
  tags            = each.value.tags
}

resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each = var.interface_endpoints

  vpc_id             = data.aws_vpc.interface_vpc[each.key].id
  service_name       = each.value.service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = data.aws_security_groups.interface_security_groups[each.key].ids
  subnet_ids         = data.aws_subnets.interface_subnets[each.key].ids
  private_dns_enabled = each.value.private_dns_enabled
  tags               = each.value.tags
}