region = "ap-northeast-1"

load_balancer = {
  name = "my-load-balancer"
  internal = false
  load_balancer_type = "application"
  security_group_names = ["alb-sg"]
  subnet_names = ["public1", "public2"]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  idle_timeout = 60
  enable_http2 = true
  tags = {
    Name = "my-load-balancer"
  }
}

target_group = {
  name = "my-target-group"
  vpc_name = "my-vpc"
  port = 80
  protocol = "HTTP"
  health_check = {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "my-target-group"
  }
}

target_instances = {
  target001 = {
    instance_name = "my-ec2-instance1"
    port             = 80
  }
  target002 = {
    instance_name = "my-ec2-instance2"
    port             = 80
  }
}
