data "aws_security_group" "security_group" {
  for_each = toset(var.rds.vpc_security_group_names)
  name     = each.value
}

data "aws_subnet" "subnet" {
  for_each = toset(var.db_subnet_group.subnet_names)
  tags = {
    Name = each.key
  }
}

resource "aws_db_instance" "db_instance" {
  instance_class               = var.rds.instance_class
  engine                       = var.rds.engine
  engine_version               = var.rds.engine_version
  identifier                   = var.rds.identifier
  allocated_storage            = var.rds.allocated_storage
  storage_type                 = var.rds.storage_type
  username                     = var.rds.user
  password                     = var.rds.password
  publicly_accessible          = var.rds.publicly_accessible
  vpc_security_group_ids       = [for sg in data.aws_security_group.security_group : sg.id]
  multi_az                     = var.rds.multi_az
  performance_insights_enabled = var.rds.performance_insights_enabled
  deletion_protection          = var.rds.deletion_protection
  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot          = var.rds.skip_final_snapshot
  tags                         = var.rds.tags
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group.name
  subnet_ids = [for subnet in data.aws_subnet.subnet : subnet.id]
  tags       = var.db_subnet_group.tags
}