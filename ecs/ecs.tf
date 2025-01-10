# VPCとサブネット
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_subnet" "ecs_subnet" {
  count             = 2
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.ecs_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "ecs-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

# インターネットゲートウェイ
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
}

# ルートテーブル
resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }
}

resource "aws_route_table_association" "ecs_rta" {
  count          = 2
  subnet_id      = aws_subnet.ecs_subnet[count.index].id
  route_table_id = aws_route_table.ecs_route_table.id
}

# ECS クラスター
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

# タスク定義
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app-container"
      image     = "021891603556.dkr.ecr.ap-northeast-1.amazonaws.com/nginx"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ECS サービス
resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.ecs_subnet[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true  # 追加
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "app-container"
    container_port   = 80
  }
}

# ロードバランサー
resource "aws_lb" "ecs_lb" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_lb_sg.id]
  subnets            = aws_subnet.ecs_subnet[*].id
}

resource "aws_lb_target_group" "ecs_tg" {
  name         = "ecs-tg"
  port         = 80
  protocol     = "HTTP"
  vpc_id       = aws_vpc.ecs_vpc.id
  target_type  = "ip"  # 修正: "instance" -> "ip"
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# セキュリティグループ
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  vpc_id      = aws_vpc.ecs_vpc.id
  description = "Allow traffic for ECS tasks"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_lb_sg" {
  name        = "ecs-lb-sg"
  vpc_id      = aws_vpc.ecs_vpc.id
  description = "Allow traffic to the ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

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
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ecr_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 不要なVPCエンドポイントのリソースを削除
# - data "aws_region" "current"
# - resource "aws_security_group" "ecr_endpoint_sg"
# - resource "aws_vpc_endpoint" "ecr_api"
# - resource "aws_vpc_endpoint" "ecr_dkr"