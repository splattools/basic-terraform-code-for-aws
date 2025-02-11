# VPCの参照
data "aws_vpc" "vpc" {
  for_each = var.security_group
  filter {
    name   = "tag:Name"
    values = [each.value.vpc_name]
  }
}

# 参照するセキュリティグループの取得
data "aws_security_group" "referenced_groups" {
  for_each = {
    for pair in flatten([
      for sg_key, sg in var.security_group : [
        for rule in concat(sg.ingress, sg.egress) : [
          for group in(rule.security_groups != null ? rule.security_groups : []) : {
            sg_key     = sg_key
            group_name = group
          }
        ]
      ]
    ]) : "${pair.sg_key}.${pair.group_name}" => pair
  }

  name = each.value.group_name
  vpc_id = data.aws_vpc.vpc[each.value.sg_key].id
}

# セキュリティグループの作成
resource "aws_security_group" "security_group" {
  for_each    = var.security_group
  name        = "${var.project}-${var.environment}-${each.value.name}"
  description = each.value.description
  vpc_id      = data.aws_vpc.vpc[each.key].id

  # インバウンドルール
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description     = ingress.value.description
      from_port      = ingress.value.from_port
      to_port        = ingress.value.to_port
      protocol       = ingress.value.protocol
      cidr_blocks    = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups != null ? [
        for group in ingress.value.security_groups :
        data.aws_security_group.referenced_groups["${each.key}.${group}"].id
      ] : null
      self = ingress.value.self
    }
  }

  # アウトバウンドルール
  dynamic "egress" {
    for_each = each.value.egress
    content {
      description     = egress.value.description
      from_port      = egress.value.from_port
      to_port        = egress.value.to_port
      protocol       = egress.value.protocol
      cidr_blocks    = egress.value.cidr_blocks
      security_groups = egress.value.security_groups != null ? [
        for group in egress.value.security_groups :
        data.aws_security_group.referenced_groups["${each.key}.${group}"].id
      ] : null
      self = egress.value.self
    }
  }

  # タイムアウト設定
  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }

  # ルール削除時の設定
  revoke_rules_on_delete = each.value.revoke_rules_on_delete

  # タグ
  tags = merge(
    each.value.tags,
    {
      Name        = "${var.project}-${var.environment}-${each.value.name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
