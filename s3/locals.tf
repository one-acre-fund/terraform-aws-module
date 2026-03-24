locals {
  common_tags = merge(var.tags, {
    Env         = var.environment
    Application = var.application
    CostCentre  = var.cost_centre
    Owner       = var.owner
    ManagedBy   = var.managed_by
    Module      = var.module
  })
}

