# ---------------------------
# Elastic Beanstalk Application
# ---------------------------
resource "aws_elastic_beanstalk_application" "this" {
  count = var.create_application ? 1 : 0

  name        = local.app_name_computed
  description = var.app_description

  appversion_lifecycle {
    service_role          = var.service_role_arn
    max_count             = 10
    delete_source_from_s3 = true
  }

  tags = merge(local.common_tags, {
    Name = local.app_name_computed
  })
}

# ---------------------------
# Elastic Beanstalk Environment
# ---------------------------
resource "aws_elastic_beanstalk_environment" "this" {
  name                = local.env_name
  application         = var.create_application ? aws_elastic_beanstalk_application.this[0].name : var.app_name
  solution_stack_name = var.solution_stack_name
  tier                = var.tier
  cname_prefix        = local.cname_prefix_computed

  # ---------------------------
  # VPC
  # ---------------------------
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.instance_subnets)
  }

  dynamic "setting" {
    for_each = length(var.elb_subnets) > 0 ? [1] : []
    content {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = join(",", var.elb_subnets)
    }
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = var.elb_scheme
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = tostring(var.associate_public_ip)
  }

  # ---------------------------
  # Launch Configuration / Instance
  # ---------------------------
  # Single instance type — overridden when instance_types list is non-empty
  dynamic "setting" {
    for_each = length(var.instance_types) == 0 ? [1] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = var.instance_type
    }
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.iam_instance_profile
  }

  dynamic "setting" {
    for_each = var.key_name != "" ? [var.key_name] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "EC2KeyName"
      value     = setting.value
    }
  }

  dynamic "setting" {
    for_each = length(var.security_groups) > 0 ? [1] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "SecurityGroups"
      value     = join(",", var.security_groups)
    }
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = var.root_volume_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = tostring(var.root_volume_size)
  }

  dynamic "setting" {
    for_each = var.root_volume_iops > 0 ? [1] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "RootVolumeIOPS"
      value     = tostring(var.root_volume_iops)
    }
  }

  dynamic "setting" {
    for_each = var.root_volume_throughput > 0 ? [1] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "RootVolumeThroughput"
      value     = tostring(var.root_volume_throughput)
    }
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "DisableIMDSv1"
    value     = tostring(var.disable_imdsv1)
  }

  dynamic "setting" {
    for_each = var.ami_id != "" ? [1] : []
    content {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "ImageId"
      value     = var.ami_id
    }
  }

  # ---------------------------
  # Auto Scaling
  # ---------------------------
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = tostring(var.min_instances)
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = tostring(var.max_instances)
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Cooldown"
    value     = tostring(var.scaling_cooldown)
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "EnableCapacityRebalancing"
    value     = tostring(var.enable_capacity_rebalancing)
  }

  # ---------------------------
  # Fleet Composition / Instance Types
  # ---------------------------
  dynamic "setting" {
    for_each = length(var.instance_types) > 0 ? [1] : []
    content {
      namespace = "aws:ec2:instances"
      name      = "InstanceTypes"
      value     = join(",", var.instance_types)
    }
  }

  dynamic "setting" {
    for_each = length(var.instance_types) > 0 ? [1] : []
    content {
      namespace = "aws:ec2:instances"
      name      = "SpotFleetOnDemandBase"
      value     = tostring(var.on_demand_base)
    }
  }

  dynamic "setting" {
    for_each = length(var.instance_types) > 0 ? [1] : []
    content {
      namespace = "aws:ec2:instances"
      name      = "SpotFleetOnDemandAboveBasePercentage"
      value     = tostring(var.on_demand_above_base_pct)
    }
  }

  dynamic "setting" {
    for_each = length(var.instance_types) > 0 ? [1] : []
    content {
      namespace = "aws:ec2:instances"
      name      = "SupportedArchitectures"
      value     = var.supported_architectures
    }
  }

  # ---------------------------
  # Scaling Trigger
  # ---------------------------
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = var.scaling_metric
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = var.scaling_statistic
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = var.scaling_unit
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Period"
    value     = tostring(var.scaling_period)
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "BreachDuration"
    value     = tostring(var.scaling_breach_duration)
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = tostring(var.scaling_upper_threshold)
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = tostring(var.scaling_upper_increment)
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = tostring(var.scaling_lower_threshold)
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement"
    value     = tostring(var.scaling_lower_increment)
  }

  # ---------------------------
  # Load Balancer
  # ---------------------------
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = var.load_balancer_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = var.service_role_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerIsShared"
    value     = tostring(var.lb_shared)
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  dynamic "setting" {
    for_each = var.tier == "WebServer" ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:application"
      name      = "Application Healthcheck URL"
      value     = var.health_check_path
    }
  }

  # HTTPS listener
  dynamic "setting" {
    for_each = var.enable_https && var.certificate_arn != "" ? [1] : []
    content {
      namespace = "aws:elbv2:listener:443"
      name      = "ListenerEnabled"
      value     = "true"
    }
  }

  dynamic "setting" {
    for_each = var.enable_https && var.certificate_arn != "" ? [1] : []
    content {
      namespace = "aws:elbv2:listener:443"
      name      = "Protocol"
      value     = "HTTPS"
    }
  }

  dynamic "setting" {
    for_each = var.enable_https && var.certificate_arn != "" ? [1] : []
    content {
      namespace = "aws:elbv2:listener:443"
      name      = "SSLCertificateArns"
      value     = var.certificate_arn
    }
  }

  # ---------------------------
  # ALB Settings
  # ---------------------------
  dynamic "setting" {
    for_each = var.load_balancer_type == "application" ? [1] : []
    content {
      namespace = "aws:elbv2:loadbalancer"
      name      = "AccessLogsS3Enabled"
      value     = tostring(var.lb_access_logs_enabled)
    }
  }

  dynamic "setting" {
    for_each = var.load_balancer_type == "application" ? [1] : []
    content {
      namespace = "aws:elbv2:loadbalancer"
      name      = "IpAddressType"
      value     = var.lb_ip_address_type
    }
  }

  # ---------------------------
  # Deployment Policy
  # ---------------------------
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = var.deployment_policy
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = var.batch_size_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = tostring(var.batch_size)
  }

  dynamic "setting" {
    for_each = contains(["Rolling", "RollingWithAdditionalBatch"], var.deployment_policy) ? [1] : []
    content {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name      = "RollingUpdateEnabled"
      value     = "true"
    }
  }

  dynamic "setting" {
    for_each = contains(["Rolling", "RollingWithAdditionalBatch"], var.deployment_policy) ? [1] : []
    content {
      namespace = "aws:autoscaling:updatepolicy:rollingupdate"
      name      = "RollingUpdateType"
      value     = var.rolling_update_type
    }
  }

  # ---------------------------
  # Managed Platform Updates
  # ---------------------------
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = tostring(var.enable_managed_updates)
  }

  dynamic "setting" {
    for_each = var.enable_managed_updates ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:managedactions"
      name      = "PreferredStartTime"
      value     = var.preferred_update_start_time
    }
  }

  dynamic "setting" {
    for_each = var.enable_managed_updates ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
      name      = "UpdateLevel"
      value     = var.managed_update_level
    }
  }

  # ---------------------------
  # CloudWatch Log Streaming
  # Log group path: /[application]/[environment]/[component]
  # ---------------------------
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = tostring(var.enable_log_streaming)
  }

  dynamic "setting" {
    for_each = var.enable_log_streaming ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "DeleteOnTerminate"
      value     = "false"
    }
  }

  dynamic "setting" {
    for_each = var.enable_log_streaming ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "RetentionInDays"
      value     = tostring(var.log_retention_days)
    }
  }

  dynamic "setting" {
    for_each = var.enable_log_streaming ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "LogGroupName"
      value     = "/${var.application}/${var.environment}/application"
    }
  }

  dynamic "setting" {
    for_each = var.enable_log_streaming ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
      name      = "HealthStreamingEnabled"
      value     = "true"
    }
  }

  dynamic "setting" {
    for_each = var.enable_log_streaming ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
      name      = "DeleteOnTerminate"
      value     = "false"
    }
  }

  dynamic "setting" {
    for_each = var.enable_log_streaming ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
      name      = "RetentionInDays"
      value     = tostring(var.log_retention_days)
    }
  }

  dynamic "setting" {
    for_each = var.enable_log_streaming ? [1] : []
    content {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
      name      = "LogGroupName"
      value     = "/${var.application}/${var.environment}/health"
    }
  }

  # ---------------------------
  # Environment Variables
  # ---------------------------
  dynamic "setting" {
    for_each = var.env_vars
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }

  tags = merge(local.common_tags, {
    Name = local.env_name
  })
}

