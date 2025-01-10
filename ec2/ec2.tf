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
  ami                    = var.ec2_instances[each.key].ami
  instance_type          = var.ec2_instances[each.key].instance_type
  key_name               = var.ec2_instances[each.key].key_name
  subnet_id              = data.aws_subnets.subnets[each.key].ids[0]
  vpc_security_group_ids = [data.aws_security_group.security_group[each.key].id]
  tags                   = var.ec2_instances[each.key].tags
  user_data              = file(var.ec2_instances[each.key].user_data)
}