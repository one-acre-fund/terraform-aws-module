locals {
  # Select subnet pool based on placement mode
  subnet_pool = var.enable_public ? var.public_subnets : var.private_subnets

  # Alternating subnet assignment: instance 0→subnet[0], 1→subnet[1], 2→subnet[0], …
  instance_subnets = [
    for i in range(var.instance_count) : local.subnet_pool[i % length(local.subnet_pool)]
  ]

  # Per-instance Name: ec2-[application]-[env]-[suffix]
  # application_names overrides per-instance; falls back to var.application for all.
  instance_names = [
    for i in range(var.instance_count) :
    "ec2-${length(var.application_names) > 0 ? var.application_names[i] : var.application}-${var.environment}-${format("%02d", i + 1)}"
  ]

  # Per-instance root EBS volume Name: vol-[application]-[env]-[suffix]
  volume_names = [
    for i in range(var.instance_count) :
    "vol-${length(var.application_names) > 0 ? var.application_names[i] : var.application}-${var.environment}-${format("%02d", i + 1)}"
  ]

  common_tags = merge(var.tags, {
    Environment  = var.environment
    Application  = var.application
    CostCentre   = var.cost_centre
    Owner        = var.owner
    ManagedBy    = var.managed_by
    map-migrated = var.map_migrated
  })

  # Flattened map of instance × additional_volume entries for for_each.
  # Key: "[instance_suffix]-[name_suffix]"  e.g. "01-data", "02-logs"
  # Keys are stable as long as instance_count and additional_volumes list order don't change.
  additional_volume_map = {
    for item in flatten([
      for i in range(var.instance_count) : [
        for vol in var.additional_volumes : {
          key            = "${format("%02d", i + 1)}-${vol.name_suffix}"
          instance_index = i
          app_name       = length(var.application_names) > 0 ? var.application_names[i] : var.application
          suffix         = format("%02d", i + 1)
          vol            = vol
        }
      ]
    ]) : item.key => item
  }
}

