output "role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "The stable and unique string identifying the IAM role"
  value       = aws_iam_role.this.id
}

output "policy_arn" {
  description = "The ARN of the custom IAM policy"
  value       = var.create_policy ? aws_iam_policy.this[0].arn : null
}

output "instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].arn : null
}

output "instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : null
}
