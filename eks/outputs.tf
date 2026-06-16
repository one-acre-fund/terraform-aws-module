output "cluster_id" {
  description = "Name/ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64-encoded certificate authority data for the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.this.version
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL (used for IAM roles for service accounts)"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_group_arns" {
  description = "Map of node group logical key to ARN"
  value       = { for k, ng in aws_eks_node_group.this : k => ng.arn }
}

output "node_group_statuses" {
  description = "Map of node group logical key to status"
  value       = { for k, ng in aws_eks_node_group.this : k => ng.status }
}

output "addon_arns" {
  description = "Map of addon name to ARN"
  value       = { for k, a in aws_eks_addon.this : k => a.arn }
}

