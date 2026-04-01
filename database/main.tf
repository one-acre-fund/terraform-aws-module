# ---------------------------
# DB Subnet Group
# ---------------------------
data "aws_db_subnet_group" "existing" {
  name = var.db_subnet_group_name
}

resource "aws_db_subnet_group" "this" {
  count      = try(data.aws_db_subnet_group.existing.id, null) == null ? 1 : 0
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = var.db_subnet_group_name
  })

}

# --------------------------
# RDS Instance
# ---------------------------
resource "aws_db_instance" "this" {
  allocated_storage           = var.storage
  identifier                  = var.db_identifier
  db_subnet_group_name        = try(data.aws_db_subnet_group.existing.name, aws_db_subnet_group.this[0].name)
  engine                      = var.engine
  engine_version              = var.engine_version
  license_model               = var.license_model
  instance_class              = var.instance_class
  username                    = var.username
  skip_final_snapshot         = var.skip_final_snapshot
  manage_master_user_password = var.manage_master_user_password
  publicly_accessible         = var.publicly_accessible
  db_name                     = contains(["postgres", "sqlserver-ee"], var.engine) ? var.db_name : null
  # <-- Add security groups here
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = merge(local.common_tags, {
    Name = var.db_identifier
  })

  # depends_on = [aws_db_subnet_group.this]
}