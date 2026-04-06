# ---------------------------
# Common / Tagging Variables
# ---------------------------

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "application" {
  description = "Application or service name (e.g., myapp, api). Used in resource naming and tags."
  type        = string
}

variable "cost_centre" {
  description = "The finance cost centre code or name (e.g., GLB-GR, KE-ASILI)."
  type        = string
}

variable "owner" {
  description = "The team or individual responsible for this resource (e.g., platform-team)."
  type        = string
}

variable "managed_by" {
  description = "Provisioning method (terraform/manual)"
  type        = string
  default     = "terraform"
}

variable "map_migrated" {
  description = "AWS map-migrated tag"
  type        = string
  default     = "migFM25HRY5PO"
}

variable "tags" {
  description = "Additional tags to merge into all resources"
  type        = map(string)
  default     = {}
}

# ---------------------------
# Elastic Beanstalk Application
# ---------------------------

variable "create_application" {
  description = "Whether to create a new Elastic Beanstalk application. Set false to reference an existing one via app_name."
  type        = bool
  default     = true
}

variable "app_name" {
  description = "Name of the Elastic Beanstalk application. If create_application = false this must reference an existing application."
  type        = string
}

variable "app_description" {
  description = "Short description of the Elastic Beanstalk application."
  type        = string
  default     = ""
}

variable "service_role_arn" {
  description = "ARN of the IAM role that Elastic Beanstalk uses to manage the environment. Required."
  type        = string
}

# ---------------------------
# Elastic Beanstalk Environment
# ---------------------------

variable "environment_name" {
  description = "Override for the EB environment name. Defaults to '<application>-<environment>'."
  type        = string
  default     = ""
}

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack name (e.g. '64bit Amazon Linux 2023 v4.3.0 running Python 3.11')."
  type        = string
}

variable "tier" {
  description = "Type of EB environment tier: 'WebServer' or 'Worker'."
  type        = string
  default     = "WebServer"

  validation {
    condition     = contains(["WebServer", "Worker"], var.tier)
    error_message = "tier must be either 'WebServer' or 'Worker'."
  }
}

variable "cname_prefix" {
  description = "Prefix for the Elastic Beanstalk CNAME (e.g. myapp-dev). Must be globally unique. Leave empty to let AWS generate one."
  type        = string
  default     = ""
}

# ---------------------------
# Networking
# ---------------------------

variable "vpc_id" {
  description = "ID of the VPC where the EB environment will be deployed."
  type        = string
}

variable "instance_subnets" {
  description = "List of subnet IDs for EC2 instances (private subnets recommended)."
  type        = list(string)
}

variable "elb_subnets" {
  description = "List of subnet IDs for the Elastic Load Balancer (public subnets for internet-facing, private for internal)."
  type        = list(string)
  default     = []
}

variable "elb_scheme" {
  description = "Load balancer scheme: 'public' or 'internal'."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "internal"], var.elb_scheme)
    error_message = "elb_scheme must be 'public' or 'internal'."
  }
}

variable "associate_public_ip" {
  description = "Whether to assign public IP addresses to EC2 instances."
  type        = bool
  default     = false
}

# ---------------------------
# EC2 / Auto Scaling
# ---------------------------

variable "instance_type" {
  description = "EC2 instance type for the EB environment (e.g. t3.small)."
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access. Leave empty to disable SSH."
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "Name or ARN of an existing IAM instance profile to assign to EB instances."
  type        = string
}

variable "min_instances" {
  description = "Minimum number of EC2 instances in the Auto Scaling group."
  type        = number
  default     = 1

  validation {
    condition     = var.min_instances >= 1
    error_message = "min_instances must be at least 1."
  }
}

variable "max_instances" {
  description = "Maximum number of EC2 instances in the Auto Scaling group."
  type        = number
  default     = 2

  validation {
    condition     = var.max_instances >= 1
    error_message = "max_instances must be at least 1."
  }
}

variable "security_groups" {
  description = "Additional security group IDs to attach to EB EC2 instances."
  type        = list(string)
  default     = []
}

# ---------------------------
# Load Balancer
# ---------------------------

variable "load_balancer_type" {
  description = "Type of load balancer: 'application', 'network', or 'classic'."
  type        = string
  default     = "application"

  validation {
    condition     = contains(["application", "network", "classic"], var.load_balancer_type)
    error_message = "load_balancer_type must be 'application', 'network', or 'classic'."
  }
}

variable "health_check_path" {
  description = "HTTP path used for the load balancer health check (e.g. /health)."
  type        = string
  default     = "/"
}

variable "enable_https" {
  description = "Whether to add an HTTPS listener (port 443) to the load balancer."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to use for the HTTPS listener. Required when enable_https = true."
  type        = string
  default     = ""
}

# ---------------------------
# Application Deployment
# ---------------------------

variable "deployment_policy" {
  description = "Deployment policy: 'AllAtOnce', 'Rolling', 'RollingWithAdditionalBatch', or 'Immutable'."
  type        = string
  default     = "Rolling"

  validation {
    condition     = contains(["AllAtOnce", "Rolling", "RollingWithAdditionalBatch", "Immutable"], var.deployment_policy)
    error_message = "deployment_policy must be one of: AllAtOnce, Rolling, RollingWithAdditionalBatch, Immutable."
  }
}

variable "rolling_update_type" {
  description = "Rolling update type: 'Time', 'Health', or 'Immutable'. Used when deployment_policy is Rolling or RollingWithAdditionalBatch."
  type        = string
  default     = "Health"
}

variable "batch_size_type" {
  description = "Type for rolling update batch sizing: 'Fixed' or 'Percentage'."
  type        = string
  default     = "Percentage"
}

variable "batch_size" {
  description = "Size of each rolling batch (number or percentage depending on batch_size_type)."
  type        = number
  default     = 30
}

# ---------------------------
# Environment Variables
# ---------------------------

variable "env_vars" {
  description = "Map of environment variable key-value pairs to inject into the EB environment."
  type        = map(string)
  default     = {}
}

# ---------------------------
# Managed Updates
# ---------------------------

variable "enable_managed_updates" {
  description = "Enable Elastic Beanstalk managed platform updates."
  type        = bool
  default     = true
}

variable "managed_update_level" {
  description = "Level of managed updates to apply: 'patch' or 'minor'."
  type        = string
  default     = "patch"

  validation {
    condition     = contains(["patch", "minor"], var.managed_update_level)
    error_message = "managed_update_level must be 'patch' or 'minor'."
  }
}

variable "preferred_update_start_time" {
  description = "Preferred window for managed updates (e.g. 'Sun:10:00'). Format: 'Day:HH:MM'."
  type        = string
  default     = "Sun:04:00"
}

# ---------------------------
# CloudWatch Log Streaming
# ---------------------------

variable "enable_log_streaming" {
  description = "Stream EB instance and health logs to CloudWatch Logs. AWS controls the log group names: /aws/elasticbeanstalk/<env>/var/log/... for instance logs and /aws/elasticbeanstalk/<env>/environment-health for health logs."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch log streams for the EB environment."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch Logs retention period."
  }
}

# ---------------------------
# Root Volume
# ---------------------------

variable "root_volume_type" {
  description = "Root EBS volume type for EB EC2 instances (gp2, gp3, io1)."
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 8
}

variable "root_volume_iops" {
  description = "Provisioned IOPS for the root EBS volume. Set > 0 to apply (required for io1, optional for gp3)."
  type        = number
  default     = 0
}

variable "root_volume_throughput" {
  description = "Throughput in MB/s for the root EBS volume. Set > 0 to apply (gp3 only)."
  type        = number
  default     = 0
}

# ---------------------------
# Instance / IMDS / AMI
# ---------------------------

variable "disable_imdsv1" {
  description = "Disable IMDSv1 on EB EC2 instances, enforcing IMDSv2 only."
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "Custom AMI ID for EB EC2 instances. Leave empty to use the platform default."
  type        = string
  default     = ""
}

# ---------------------------
# Fleet Composition
# ---------------------------

variable "instance_types" {
  description = "List of EC2 instance types for mixed-instance Auto Scaling (e.g. ['t3.large', 't3.medium']). When non-empty, supersedes instance_type and uses aws:ec2:instances settings."
  type        = list(string)
  default     = []
}

variable "on_demand_base" {
  description = "Minimum number of On-Demand instances in the Auto Scaling group baseline."
  type        = number
  default     = 0
}

variable "on_demand_above_base_pct" {
  description = "Percentage of On-Demand instances above on_demand_base. Remainder are Spot. 100 = all On-Demand."
  type        = number
  default     = 100
}

variable "supported_architectures" {
  description = "CPU architecture for instance type selection: x86_64 or arm64."
  type        = string
  default     = "x86_64"
}

variable "enable_capacity_rebalancing" {
  description = "Enable Capacity Rebalancing for Spot Instances in the Auto Scaling group."
  type        = bool
  default     = false
}

# ---------------------------
# Scaling Trigger
# ---------------------------

variable "scaling_cooldown" {
  description = "Cooldown period in seconds between Auto Scaling activities."
  type        = number
  default     = 360
}

variable "scaling_metric" {
  description = "CloudWatch metric used to trigger Auto Scaling (e.g. NetworkOut, CPUUtilization)."
  type        = string
  default     = "NetworkOut"
}

variable "scaling_statistic" {
  description = "Statistic to apply to the scaling metric: Average, Minimum, Maximum, Sum."
  type        = string
  default     = "Average"
}

variable "scaling_unit" {
  description = "Unit for the scaling metric (e.g. Bytes, Percent, Count)."
  type        = string
  default     = "Bytes"
}

variable "scaling_period" {
  description = "Time period in minutes over which the scaling metric is evaluated."
  type        = number
  default     = 5
}

variable "scaling_breach_duration" {
  description = "Number of consecutive periods the metric must breach a threshold before scaling."
  type        = number
  default     = 5
}

variable "scaling_upper_threshold" {
  description = "Upper metric threshold that triggers a scale-out event."
  type        = number
  default     = 6000000
}

variable "scaling_upper_increment" {
  description = "Number of instances to add during a scale-out event."
  type        = number
  default     = 1
}

variable "scaling_lower_threshold" {
  description = "Lower metric threshold that triggers a scale-in event."
  type        = number
  default     = 2000000
}

variable "scaling_lower_increment" {
  description = "Number of instances to remove during a scale-in event (use a negative value)."
  type        = number
  default     = -1
}

# ---------------------------
# Load Balancer (ALB)
# ---------------------------

variable "lb_shared" {
  description = "Whether the load balancer is shared across EB environments."
  type        = bool
  default     = false
}

variable "lb_access_logs_enabled" {
  description = "Enable ALB access log storage to S3."
  type        = bool
  default     = false
}

variable "lb_ip_address_type" {
  description = "IP address type for the ALB: ipv4 or dualstack."
  type        = string
  default     = "ipv4"
}

