variable "project" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "db_password" { type = string }

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.environment}-db-subnet"
  subnet_ids = var.public_subnet_ids
}

resource "aws_security_group" "db" {
  name        = "${var.project}-${var.environment}-db-sg"
  description = "Database security group VPC only"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "PostgreSQL from VPC only"
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "PostgreSQL to VPC only"
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project}-${var.environment}-rds-monitoring"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole" Effect = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "auth" {
  identifier             = "${var.project}-${var.environment}-authdb"
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "authdb"
  username               = "authuser"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible                 = false
  storage_encrypted                   = true
  skip_final_snapshot                 = false
  deletion_protection                 = true
  backup_retention_period             = 7
  iam_database_authentication_enabled = true
  auto_minor_version_upgrade          = true
  multi_az                            = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = "arn:aws:kms:eu-west-2:111122223333:key/placeholder"
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_monitoring.arn
}

resource "aws_db_instance" "transactions" {
  identifier             = "${var.project}-${var.environment}-txdb"
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "transactiondb"
  username               = "txuser"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible                 = false
  storage_encrypted                   = true
  skip_final_snapshot                 = false
  deletion_protection                 = true
  backup_retention_period             = 7
  iam_database_authentication_enabled = true
  auto_minor_version_upgrade          = true
  multi_az                            = true
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = "arn:aws:kms:eu-west-2:111122223333:key/placeholder"
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_monitoring.arn
}
