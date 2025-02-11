# Gateway Endpointのためのデータソース
data "aws_vpc" "gateway_vpc" {
  for_each = var.gateway_endpoints
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

# Interface Endpointのためのデータソース
data "aws_vpc" "interface_vpc" {
  for_each = var.interface_endpoints
  filter {
    name   = "tag:Name"
    values = [each.value.vpc_name]
  }
}

data "aws_subnet" "interface_subnets" {
  for_each = {
    for pair in flatten([
      for endpoint_key, endpoint in var.interface_endpoints : [
        for subnet_name in endpoint.subnet_names : {
          endpoint_key = endpoint_key
          subnet_name = subnet_name
        }
      ]
    ]) : "${pair.endpoint_key}.${pair.subnet_name}" => pair
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.interface_vpc[each.value.endpoint_key].id]
  }
  filter {
    name   = "tag:Name"
    values = [each.value.subnet_name]
  }
}

data "aws_security_group" "interface_security_groups" {
  for_each = {
    for pair in flatten([
      for endpoint_key, endpoint in var.interface_endpoints : [
        for sg_name in endpoint.security_group_names : {
          endpoint_key = endpoint_key
          sg_name     = sg_name
        }
      ]
    ]) : "${pair.endpoint_key}.${pair.sg_name}" => pair
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.interface_vpc[each.value.endpoint_key].id]
  }
  filter {
    name   = "tag:Name"
    values = [each.value.sg_name]
  }
}

# Gateway Endpoint
resource "aws_vpc_endpoint" "gateway_endpoint" {
  for_each = var.gateway_endpoints

  vpc_id            = data.aws_vpc.gateway_vpc[each.key].id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.gateway_route_tables[each.key].ids
  auto_accept       = each.value.auto_accept

  policy = each.value.policy != null ? each.value.policy : null

  tags = merge(
    each.value.tags,
    {
      Name        = "${var.project}-${var.environment}-${each.key}-gw-endpoint"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

# Interface Endpoint
resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each = var.interface_endpoints

  vpc_id             = data.aws_vpc.interface_vpc[each.key].id
  service_name       = each.value.service_name
  vpc_endpoint_type  = "Interface"
  auto_accept        = each.value.auto_accept
  ip_address_type    = each.value.ip_address_type
  private_dns_enabled = each.value.private_dns_enabled

  security_group_ids = [
    for sg_key in each.value.security_group_names :
    data.aws_security_group.interface_security_groups["${each.key}.${sg_key}"].id
  ]

  subnet_ids = [
    for subnet_key in each.value.subnet_names :
    data.aws_subnet.interface_subnets["${each.key}.${subnet_key}"].id
  ]

  policy = each.value.policy != null ? each.value.policy : null

  dynamic "dns_options" {
    for_each = each.value.dns_options != null ? [each.value.dns_options] : []
    content {
      dns_record_ip_type = dns_options.value.dns_record_ip_type
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(
    each.value.tags,
    {
      Name        = "${var.project}-${var.environment}-${each.key}-if-endpoint"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}
