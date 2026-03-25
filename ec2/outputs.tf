output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.this[*].id
}

output "instance_arns" {
  description = "List of EC2 instance ARNs"
  value       = aws_instance.this[*].arn
}

output "instance_names" {
  description = "List of EC2 instance names (ec2-[application]-[env]-[suffix])"
  value       = local.instance_names
}

output "private_ips" {
  description = "List of private IP addresses of the EC2 instances"
  value       = aws_instance.this[*].private_ip
}

output "public_ips" {
  description = "List of public IP addresses (null for private instances)"
  value       = aws_instance.this[*].public_ip
}

output "private_dns_names" {
  description = "List of private DNS names of the EC2 instances"
  value       = aws_instance.this[*].private_dns
}

output "subnet_assignments" {
  description = "Map of instance name to subnet ID, showing the alternating subnet distribution"
  value = {
    for i in range(var.instance_count) :
    local.instance_names[i] => local.instance_subnets[i]
  }
}
