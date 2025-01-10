data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.target_group.vpc_name]
  }
}

data "aws_security_group" "security_groups" {
  filter {
    name   = "tag:Name"
    values = var.load_balancer.security_group_names
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "tag:Name"
    values = var.load_balancer.subnet_names
  }
}

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

resource "aws_lb" "lb" {
  name               = var.load_balancer.name
  internal           = var.load_balancer.internal
  load_balancer_type = var.load_balancer.load_balancer_type
  security_groups    = [data.aws_security_group.security_groups.id]
  subnets            = data.aws_subnets.subnets.ids
  enable_deletion_protection = var.load_balancer.enable_deletion_protection
  enable_cross_zone_load_balancing = var.load_balancer.enable_cross_zone_load_balancing
  idle_timeout = var.load_balancer.idle_timeout
  enable_http2 = var.load_balancer.enable_http2
  tags = var.load_balancer.tags
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = var.target_group.name
  vpc_id   = data.aws_vpc.vpc.id
  port     = var.target_group.port
  protocol = var.target_group.protocol

  health_check {
    path                = var.target_group.health_check.path
    protocol            = var.target_group.health_check.protocol
    port                = var.target_group.health_check.port
    interval            = var.target_group.health_check.interval
    timeout             = var.target_group.health_check.timeout
    healthy_threshold   = var.target_group.health_check.healthy_threshold
    unhealthy_threshold = var.target_group.health_check.unhealthy_threshold
  }
  tags = var.target_group.tags
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  for_each = var.target_instances
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = data.aws_instance.instances[each.key].id
  port             = each.value.port
}
