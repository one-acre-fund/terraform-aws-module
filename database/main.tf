# ---------------------------
# Random Password
# ---------------------------
resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+"
}

# ---------------------------
# DB Subnet Group
# ---------------------------


# resource "aws_db_subnet_group" "this" {
#   count      = try(data.aws_db_subnet_group.existing.id, null) == null ? 1 : 0
#   name       = var.db_subnet_group_name
#   subnet_ids = var.subnet_ids

#   tags = merge(local.common_tags, {
#     Name = var.db_subnet_group_name
#   })

# }

# ---------------------------
# IAM Role for Enhanced Monitoring
# ---------------------------
resource "aws_iam_role" "rds_monitoring" {
  name = "rds-monitoring-${var.db_identifier}-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ---------------------------
# DB Parameter Group (individual per instance)
# ---------------------------
resource "aws_db_parameter_group" "this" {
  name        = var.db_identifier
  family      = var.engine == "sqlserver-ee" ? "sqlserver-ee-15.0" : "postgres16"
  description = "Parameter group for ${var.db_identifier}"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = merge(local.common_tags, {
    Name = var.db_identifier
  })
}

# --------------------------
# RDS Instance
# ---------------------------
resource "aws_db_instance" "this" {
  allocated_storage      = var.storage
  identifier             = var.db_identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  license_model          = var.license_model
  instance_class         = var.instance_class
  username               = var.username
  password               = random_password.this.result
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = var.publicly_accessible
  db_subnet_group_name   = var.db_subnet_group_name
  db_name                = contains(["postgres", "sqlserver-ee"], var.engine) ? var.db_name : null
  vpc_security_group_ids = var.vpc_security_group_ids
  deletion_protection    = var.deletion_protection
  apply_immediately      = var.apply_immediately
  multi_az               = var.multi_az_enabled
  max_allocated_storage  = var.environment == "prod" ? var.max_allocated_storage : null
  # Encryption
  storage_encrypted = true
  kms_key_id        = var.kms_key_id != "" ? var.kms_key_id : null

  # Individual parameter group
  parameter_group_name = aws_db_parameter_group.this.name

  # Enhanced Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  tags = merge(local.common_tags, {
    Name = var.db_identifier
  })

  depends_on = [aws_iam_role_policy_attachment.rds_monitoring]
}

# ---------------------------
# Secrets Manager Secret (individual per RDS, named /<env>/<app>/<rds-name>)
# ---------------------------
resource "aws_secretsmanager_secret" "rds" {
  name        = "/${var.environment}/${var.application}/${var.db_identifier}"
  description = "Credentials for RDS instance ${var.db_identifier}"
  kms_key_id  = var.kms_key_id != "" ? var.kms_key_id : "alias/aws/secretsmanager"

  tags = merge(local.common_tags, {
    Name = "/${var.environment}/${var.application}/${var.db_identifier}"
  })
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id

  secret_string = jsonencode({
    engine           = var.engine
    host             = aws_db_instance.this.address
    port             = aws_db_instance.this.port
    username         = aws_db_instance.this.username
    password         = random_password.this.result
    dbname           = aws_db_instance.this.db_name
    rds_instance_arn = aws_db_instance.this.arn
  })
}