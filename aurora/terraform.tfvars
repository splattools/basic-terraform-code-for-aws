region = "ap-northeast-1"

aurora_cluster = {
  cluster_identifier = "my-aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.11.5"
  instance_class     = "db.r4.large"
  username           = "admin"
  password           = "password"
  db_subnet_group    = "my-db-subnet-group"
  vpc_security_group_names = ["rds-sg"]
  tags = {
    Name        = "my-aurora-cluster"
    Environment = "dev"
  }
}

aurora_instance = {
  instance_class     = "db.r4.large"
  engine             = "aurora"
}

db_subnet_group = {
  name         = "my-db-subnet-group"
  subnet_names = ["private1", "private2"]
  tags = {
    Name        = "my-db-subnet-group"
    Environment = "dev"
  }
}