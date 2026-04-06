locals {
  common_tags = merge(var.tags, {
    Environment  = var.environment
    Application  = var.application
    CostCentre   = var.cost_centre
    Owner        = var.owner
    ManagedBy    = var.managed_by
    map-migrated = var.map_migrated
  })

  # elasticbeanstalk-<application>-<environment>
  app_name_computed = "elasticbeanstalk-${var.application}-${var.environment}"

  # elasticbeanstalk-env-<application>-<environment>
  env_name = var.environment_name != "" ? var.environment_name : "elasticbeanstalk-env-${var.application}-${var.environment}"

  # <application>-<environment>  →  <application>-<environment>.eu-west-1.elasticbeanstalk.com
  cname_prefix_computed = var.cname_prefix != "" ? var.cname_prefix : "${var.application}-${var.environment}"
}
