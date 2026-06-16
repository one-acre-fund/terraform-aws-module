# ---------------------------
# EKS Cluster
# ---------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = var.cluster_role_arn

  deletion_protection           = var.deletion_protection
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons
  enabled_cluster_log_types     = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  kubernetes_network_config {
    ip_family         = var.ip_family
    service_ipv4_cidr = var.service_ipv4_cidr
    elastic_load_balancing {
      enabled = var.elastic_load_balancing_enabled
    }
  }

  upgrade_policy {
    support_type = var.support_type
  }

  control_plane_scaling_config {
    tier = var.control_plane_scaling_tier
  }

  tags = merge(local.common_tags, {
    Name = var.cluster_name
  })

  lifecycle {
    ignore_changes = [
      # set at creation; cannot be changed after
      kubernetes_network_config,
      # AWS-managed; not configurable via Terraform
      zonal_shift_config,
      # tags on imported resources may differ; managed via default_tags
      tags,
      tags_all,
    ]
  }
}

# ---------------------------
# EKS Add-ons
# ---------------------------
resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = each.value.addon_version
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  service_account_role_arn    = each.value.service_account_role_arn
  configuration_values        = each.value.configuration_values
  preserve                    = each.value.preserve

  tags = merge(local.common_tags, {
    Name = "${aws_eks_cluster.this.name}-${each.key}"
  })

  lifecycle {
    ignore_changes = [
      # tags on imported addons may differ; managed via default_tags
      tags,
      tags_all,
      # pod identity associations are managed separately via aws_eks_pod_identity_association
      pod_identity_association,
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

  instance_types  = each.value.instance_types
  ami_type        = each.value.ami_type
  release_version = each.value.ami_release_version
  capacity_type   = each.value.capacity_type
  disk_size       = each.value.disk_size

  scaling_config {
    min_size     = each.value.min_size
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable            = each.value.max_unavailable_percentage == null ? each.value.max_unavailable : null
    max_unavailable_percentage = each.value.max_unavailable_percentage
    update_strategy            = each.value.update_strategy
  }

  node_repair_config {
    enabled = each.value.node_repair_enabled
  }

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  dynamic "remote_access" {
    for_each = each.value.ec2_ssh_key != null ? [1] : []
    content {
      ec2_ssh_key               = each.value.ec2_ssh_key
      source_security_group_ids = each.value.source_security_group_ids
    }
  }

  labels = each.value.labels

  tags = merge(local.common_tags, {
    Name = each.value.node_group_name
  }, each.value.tags)

  lifecycle {
    ignore_changes = [
      # desired_size is managed by cluster autoscaler
      scaling_config[0].desired_size,
      # tags on imported resources may differ; managed via default_tags
      tags,
      tags_all,
    ]
  }
}
