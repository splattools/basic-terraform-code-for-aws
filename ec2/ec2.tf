data "aws_subnets" "subnets" {
  for_each = var.ec2_instances
  filter {
    name   = "tag:Name"
    values = [each.value.subnet_name]
  }
}

data "aws_security_group" "security_group" {
  for_each = var.ec2_instances
  filter {
    name   = "tag:Name"
    values = each.value.vpc_security_group_names
  }
}

resource "aws_instance" "ec2" {
  for_each               = var.ec2_instances
  
  # 基本設定
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  key_name              = each.value.key_name
  subnet_id             = data.aws_subnets.subnets[each.key].ids[0]
  vpc_security_group_ids = [data.aws_security_group.security_group[each.key].id]
  
  # 明示的な設定
  monitoring            = each.value.monitoring
  disable_api_termination = each.value.disable_api_termination
  instance_initiated_shutdown_behavior = "stop"
  
  # ルートボリューム設定
  root_block_device {
    volume_size = each.value.root_volume_size
    volume_type = each.value.root_volume_type
    iops       = each.value.root_volume_type == "gp3" || each.value.root_volume_type == "io2" ? each.value.root_volume_iops : null
    throughput = each.value.root_volume_type == "gp3" ? each.value.root_volume_throughput : null
    encrypted  = true
    delete_on_termination = true
  }
  
  # ユーザーデータ
  user_data = file(each.value.user_data)
  
  # タグ
  tags = merge(
    each.value.tags,
    {
      Name        = "${var.project}-${var.environment}-ec2-${each.key}"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  )
}
