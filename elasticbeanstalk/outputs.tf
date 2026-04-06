output "application_name" {
  description = "Name of the Elastic Beanstalk application"
  value       = var.create_application ? aws_elastic_beanstalk_application.this[0].name : var.app_name
}

output "application_arn" {
  description = "ARN of the Elastic Beanstalk application (empty when create_application = false)"
  value       = var.create_application ? aws_elastic_beanstalk_application.this[0].arn : null
}

output "environment_id" {
  description = "ID of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.this.id
}

output "environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.this.name
}

output "environment_arn" {
  description = "ARN of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.this.arn
}

output "endpoint_url" {
  description = "DNS hostname of the Elastic Beanstalk environment load balancer"
  value       = aws_elastic_beanstalk_environment.this.endpoint_url
}

output "cname" {
  description = "CNAME of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.this.cname
}

output "tier" {
  description = "Tier of the Elastic Beanstalk environment (WebServer or Worker)"
  value       = aws_elastic_beanstalk_environment.this.tier
}

output "solution_stack_name" {
  description = "Solution stack (platform) running in the environment"
  value       = aws_elastic_beanstalk_environment.this.solution_stack_name
}
