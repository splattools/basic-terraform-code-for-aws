# 既存のVPCの参照
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.service.network_configuration.vpc_name]
  }
}

# サブネットの参照
data "aws_subnet" "subnets" {
  for_each = toset(var.service.network_configuration.subnet_names)
  
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
  
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

# セキュリティグループの参照
data "aws_security_group" "security_groups" {
  for_each = toset(var.service.network_configuration.security_group_names)
  
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
  
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

# ECSクラスター
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-${var.environment}-${var.cluster.name}"

  setting {
    name  = "containerInsights"
    value = var.cluster.container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.cluster.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.cluster.name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

# ECSクラスターのキャパシティプロバイダー
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.cluster.name
  capacity_providers = var.cluster.capacity_providers

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# タスク実行ロール
resource "aws_iam_role" "execution_role" {
  name = "${var.project}-${var.environment}-${var.task_definition.execution_role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.task_definition.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.task_definition.execution_role_name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

# タスク実行ロールのポリシーアタッチメント
resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# タスクロール（オプショナル）
resource "aws_iam_role" "task_role" {
  count = var.task_definition.task_role_name != null ? 1 : 0
  
  name = "${var.project}-${var.environment}-${var.task_definition.task_role_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.task_definition.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.task_definition.task_role_name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

# タスク定義
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project}-${var.environment}-${var.task_definition.family}"
  network_mode             = var.task_definition.network_mode
  requires_compatibilities = var.task_definition.requires_compatibilities
  cpu                      = var.task_definition.cpu
  memory                   = var.task_definition.memory
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn           = var.task_definition.task_role_name != null ? aws_iam_role.task_role[0].arn : null

  dynamic "volume" {
    for_each = var.task_definition.volumes != null ? var.task_definition.volumes : []
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id = efs_volume_configuration.value.file_system_id
          root_directory = efs_volume_configuration.value.root_directory
        }
      }
    }
  }

  container_definitions = jsonencode(var.task_definition.containers)

  tags = merge(
    var.task_definition.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.task_definition.family}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

# ECSサービス
resource "aws_ecs_service" "service" {
  name                = "${var.project}-${var.environment}-${var.service.name}"
  cluster             = aws_ecs_cluster.cluster.id
  task_definition    = aws_ecs_task_definition.task.arn
  desired_count      = var.service.desired_count
  launch_type        = var.service.launch_type
  platform_version   = "LATEST"
  
  force_new_deployment    = var.service.force_new_deployment
  enable_execute_command = var.service.enable_execute_command

  dynamic "deployment_circuit_breaker" {
    for_each = var.service.deployment_configuration.deployment_circuit_breaker != null ? [var.service.deployment_configuration.deployment_circuit_breaker] : []
    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  deployment_maximum_percent         = var.service.deployment_configuration.maximum_percent
  deployment_minimum_healthy_percent = var.service.deployment_configuration.minimum_healthy_percent

  network_configuration {
    subnets          = [for subnet in data.aws_subnet.subnets : subnet.id]
    security_groups  = [for sg in data.aws_security_group.security_groups : sg.id]
    assign_public_ip = var.service.network_configuration.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.service.load_balancer != null ? [var.service.load_balancer] : []
    content {
      target_group_arn = aws_lb_target_group.target_group[0].arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = var.service.service_registries != null ? [var.service.service_registries] : []
    content {
      registry_arn = service_registries.value.registry_arn
      port         = service_registries.value.port
    }
  }

  tags = merge(
    var.service.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.service.name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ターゲットグループ（ロードバランサーが設定されている場合）
resource "aws_lb_target_group" "target_group" {
  count = var.service.load_balancer != null ? 1 : 0

  name        = "${var.project}-${var.environment}-${var.service.load_balancer.target_group_name}"
  port        = var.service.load_balancer.container_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 3
  }

  tags = merge(
    var.service.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.service.load_balancer.target_group_name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
