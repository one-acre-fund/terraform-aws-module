locals {
  vpc_name = "vpc-${var.environment}"

  common_tags = merge(var.tags, {
    Environment   = var.environment
    Application   = var.application
    CostCentre    = var.cost_centre
    Owner         = var.owner
    ManagedBy     = var.managed_by
    Module        = var.module
    map-migrated  = "migFM25HRY5PO"
  })

  nat_gateway_count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  ) : 0
}
