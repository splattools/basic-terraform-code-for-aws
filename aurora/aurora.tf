resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = var.aurora_cluster["cluster_identifier"]
  engine            = var.aurora_cluster["engine"]
  engine_version    = var.aurora_cluster["engine_version"]
  master_username   = var.aurora_cluster["username"]
  master_password   = var.aurora_cluster["password"]
  db_subnet_group_name = aws_db_subnet_group.name.name
  vpc_security_group_ids = [aws_security_group.name.id]
  tags = var.aurora_cluster["tags"]
}


resource "aws_rds_cluster_instance" "name" {
  count = var.aurora_cluster["instance_count"]
  identifier = "${var.aurora_cluster["cluster_identifier"]}-${count.index}"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class = var.aurora_cluster["instance_class"]
  engine = var.aurora_cluster["engine"]
  engine_version = var.aurora_cluster["engine_version"]
  publicly_accessible = var.aurora_cluster["publicly_accessible"]
  tags = var.aurora_cluster["tags"]
}