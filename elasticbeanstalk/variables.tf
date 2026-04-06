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
