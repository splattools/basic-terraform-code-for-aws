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

# パラメータグループ
resource "aws_db_parameter_group" "parameter_group" {
  count  = var.rds.parameter_group_family != null ? 1 : 0
  
  family = var.rds.parameter_group_family
  name   = "${var.project}-${var.environment}-pg"
  
  dynamic "parameter" {
    for_each = var.rds.parameter_group_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-pg"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

resource "aws_db_instance" "db_instance" {
  # 基本設定
  identifier     = "${var.project}-${var.environment}-${var.rds.identifier}"
  instance_class = var.rds.instance_class
  engine         = var.rds.engine
  engine_version = var.rds.engine_version
  
  # ストレージ設定
  allocated_storage     = var.rds.allocated_storage
  max_allocated_storage = var.rds.max_allocated_storage
  storage_type          = var.rds.storage_type
  storage_encrypted     = var.rds.storage_encrypted
  
  # 認証設定
  username = var.rds.user
  password = var.rds.password
  
  # ネットワーク設定
  publicly_accessible    = var.rds.publicly_accessible
  vpc_security_group_ids = [for sg in data.aws_security_group.security_group : sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  
  # 可用性設定
  multi_az = var.rds.multi_az
  
  # パフォーマンス設定
  performance_insights_enabled          = var.rds.performance_insights_enabled
  performance_insights_retention_period = var.rds.performance_insights_retention_period
  
  # バックアップ設定
  backup_retention_period = var.rds.backup_retention_period
  backup_window          = var.rds.backup_window
  
  # メンテナンス設定
  maintenance_window         = var.rds.maintenance_window
  auto_minor_version_upgrade = var.rds.auto_minor_version_upgrade
  
  # 削除保護設定
  deletion_protection   = var.rds.deletion_protection
  skip_final_snapshot  = var.rds.skip_final_snapshot
  final_snapshot_identifier = var.rds.skip_final_snapshot ? null : (
    var.rds.final_snapshot_identifier != null ? var.rds.final_snapshot_identifier :
    "${var.project}-${var.environment}-${var.rds.identifier}-final-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  )
  copy_tags_to_snapshot = var.rds.copy_tags_to_snapshot
  
  # パラメータグループ
  parameter_group_name = var.rds.parameter_group_family != null ? aws_db_parameter_group.parameter_group[0].name : null
  
  # タグ
  tags = merge(
    var.rds.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.rds.identifier}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.project}-${var.environment}-${var.db_subnet_group.name}"
  subnet_ids = [for subnet in data.aws_subnet.subnet : subnet.id]
  
  tags = merge(
    var.db_subnet_group.tags,
    {
      Name        = "${var.project}-${var.environment}-${var.db_subnet_group.name}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}
