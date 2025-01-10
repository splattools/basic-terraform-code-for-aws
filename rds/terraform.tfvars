region = "ap-northeast-1"

rds = {
  instance_class               = "db.t4g.micro"
  engine                       = "mysql"
  engine_version               = "8.0.39"
  identifier                   = "my-rds"
  allocated_storage            = 20
  storage_type                 = "gp3"
  publicly_accessible          = false
  user                         = "admin"
  password                     = "password"
  vpc_security_group_names     = ["rds-sg"]
  multi_az                     = true
  performance_insights_enabled = false
  deletion_protection          = false
  skip_final_snapshot          = true
  tags = {
    Name        = "my-rds"
    Environment = "dev"
  }
}

db_subnet_group = {
  name         = "my-db-subnet-group"
  subnet_names = ["private1", "private2"]
  tags = {
    Name        = "my-db-subnet-group"
    Environment = "dev"
  }
}