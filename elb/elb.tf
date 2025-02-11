# VPCの参照
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.target_group.vpc_name]
  }
}

# セキュリティグループの参照
data "aws_security_group" "security_groups" {
  for_each = toset(var.load_balancer.security_group_names)
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

# サブネットの参照
data "aws_subnets" "subnets" {
  filter {
    name   = "tag:Name"
    values = var.load_balancer.subnet_names
  }
}

# ターゲットインスタンスの参照
data "aws_instance" "instances" {
  for_each = var.target_instances
  filter {
    name   = "tag:Name"
    values = [each.value.instance_name]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# ロードバランサーの作成
resource "aws_lb" "lb" {
  name               = "${var.project}-${var.environment}-${var.load_balancer.name}"
  internal           = var.load_balancer.internal
  load_balancer_type = var.load_balancer.load_balancer_type
  security_groups    = [for sg in data.aws_security_group.security_groups : sg.id]
  subnets            = data.aws_subnets.subnets.ids

  # 基本設定
  enable_deletion_protection       = var.load_balancer.enable_deletion_protection
  enable_cross_zone_load_balancing = var.load_balancer.enable_cross_zone_load_balancing
  idle_timeout                     = var.load_balancer.idle_timeout
  enable_http2                     = var.load_balancer.enable_http2
  drop_invalid_header_fields       = var.load_balancer.drop_invalid_header_fields
  preserve_host_header            = var.load_balancer.preserve_host_header
  desync_mitigation_mode          = var.load_balancer.desync_mitigation_mode

  # アクセスログ設定
  dynamic "access_logs" {
    for_each = var.load_balancer.access_logs != null ? [var.load_balancer.access_logs] : []
    content {
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
      enabled = access_logs.value.enabled
    }
  }

  # タグ
  tags = merge(
    var.load_balancer.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.load_balancer.name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

# ターゲットグループの作成
resource "aws_lb_target_group" "lb_target_group" {
  name        = "${var.project}-${var.environment}-${var.target_group.name}"
  vpc_id      = data.aws_vpc.vpc.id
  port        = var.target_group.port
  protocol    = var.target_group.protocol
  target_type = var.target_group.target_type

  # デレジストレーション設定
  deregistration_delay = var.target_group.deregistration_delay
  slow_start          = var.target_group.slow_start
  proxy_protocol_v2   = var.target_group.proxy_protocol_v2

  # スティッキネス設定
  dynamic "stickiness" {
    for_each = var.target_group.stickiness != null ? [var.target_group.stickiness] : []
    content {
      enabled         = stickiness.value.enabled
      type           = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
    }
  }

  # ヘルスチェック設定
  health_check {
    path                = var.target_group.health_check.path
    protocol            = var.target_group.health_check.protocol
    port                = var.target_group.health_check.port
    interval            = var.target_group.health_check.interval
    timeout             = var.target_group.health_check.timeout
    healthy_threshold   = var.target_group.health_check.healthy_threshold
    unhealthy_threshold = var.target_group.health_check.unhealthy_threshold
    matcher             = var.target_group.health_check.matcher
  }

  # タグ
  tags = merge(
    var.target_group.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.target_group.name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# HTTPリスナーの作成
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# HTTPSリスナーの作成（設定がある場合）
resource "aws_lb_listener" "https_listener" {
  count = var.load_balancer.https_listener != null ? 1 : 0

  load_balancer_arn = aws_lb.lb.arn
  port              = var.load_balancer.https_listener.port
  protocol          = "HTTPS"
  ssl_policy        = var.load_balancer.https_listener.ssl_policy
  certificate_arn   = var.load_balancer.https_listener.certificate_arn

  default_action {
    type             = var.load_balancer.https_listener.default_action
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# ターゲットグループのアタッチメント
resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  for_each = var.target_instances
  
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = data.aws_instance.instances[each.key].id
  port             = each.value.port
}
