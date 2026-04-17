output "aws_db_instance" {
  description = "The Name of the DB instance"
  value       = aws_db_instance.this.db_name
}

output "db_instance_id" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "parameter_group_name" {
  description = "The name of the DB parameter group"
  value       = aws_db_parameter_group.this.name
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret for this RDS instance"
  value       = aws_secretsmanager_secret.rds.arn
}

output "secret_name" {
  description = "The name of the Secrets Manager secret (/<env>/<app>/<rds-name>)"
  value       = aws_secretsmanager_secret.rds.name
}