resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnets"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]

  tags = {
    Name = "${var.project_name}-db-subnets"
  }
}


resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-database"

  engine         = "postgres"
  instance_class = "db.t4g.micro"

  db_name  = "eventtickets"
  username = "ticketadmin"
  port     = 5432

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds.id,
  ]

  publicly_accessible = false
  multi_az            = false

  manage_master_user_password = true

  backup_retention_period    = 1
  auto_minor_version_upgrade = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true
  apply_immediately        = true

  tags = {
    Name = "${var.project_name}-database"
  }
}