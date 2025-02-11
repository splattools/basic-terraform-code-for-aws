region      = "ap-northeast-1"
project     = "myapp"
environment = "dev"

cluster = {
  name               = "main"
  container_insights = true
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  tags = {
    Service = "main-cluster"
  }
}

task_definition = {
  family               = "web-app"
  cpu                  = "256"
  memory               = "512"
  execution_role_name  = "ecs-task-execution-role"
  task_role_name      = "ecs-task-role"
  containers = [
    {
      name      = "app"
      image     = "021891603556.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      port_mappings = [
        {
          container_port = 80
          host_port     = 80
          protocol      = "tcp"
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/web-app"
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ]
  tags = {
    Service = "web-app"
  }
}

service = {
  name           = "web-app"
  desired_count  = 2
  force_new_deployment = true
  enable_execute_command = true
  deployment_configuration = {
    maximum_percent         = 200
    minimum_healthy_percent = 100
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
  }
  network_configuration = {
    vpc_name            = "main-vpc"
    subnet_names        = ["private-subnet-1a", "private-subnet-1c"]
    security_group_names = ["ecs-service-sg"]
    assign_public_ip   = false
  }
  load_balancer = {
    target_group_name = "web-app-tg"
    container_name    = "app"
    container_port    = 80
  }
  tags = {
    Service = "web-app"
  }
}
