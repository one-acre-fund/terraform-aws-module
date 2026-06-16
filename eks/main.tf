# ---------------------------
# EKS Cluster
# ---------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = merge(local.common_tags, {
    Name = var.cluster_name
  })

  lifecycle {
    ignore_changes = [
      # set by AWS at creation and cannot be changed
      kubernetes_network_config,
      # AWS-managed attribute, not supported in Terraform config
      zonal_shift_config,
    ]
  }
}

# ---------------------------
# Managed Node Groups
# ---------------------------
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value.node_group_name
  node_role_arn   = each.value.node_role_arn
  subnet_ids      = each.value.subnet_ids

  instance_types = each.value.instance_types
  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type

  scaling_config {
    min_size     = each.value.min_size
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
  }

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  labels = each.value.labels

  tags = merge(local.common_tags, {
    Name = each.value.node_group_name
  }, each.value.tags)

  lifecycle {
    # desired_size is managed by cluster autoscaler; ignore drift
    ignore_changes = [scaling_config[0].desired_size]
  }
}
