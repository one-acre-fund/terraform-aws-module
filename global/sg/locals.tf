locals {
  common_tags = merge(var.tags, {
    Environment  = var.environment
    Application  = var.application
    CostCentre   = var.cost_centre
    Owner        = var.owner
    ManagedBy    = var.managed_by
    map-migrated = var.map_migrated
  })

}
