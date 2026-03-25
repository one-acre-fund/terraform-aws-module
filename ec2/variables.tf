variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "application" {
  description = "Default application name used in naming and tags (e.g., odoo, fineract). Overridden per-instance by application_names."
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
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}


# ---------------------------
# EC2 Variables
# ---------------------------

variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1
    error_message = "instance_count must be at least 1."
  }
}

variable "application_names" {
  description = "Per-instance application names used in the Name tag (ec2-[application]-[env]-[suffix]). Must be empty (use application for all) or have exactly instance_count elements."
  type        = list(string)
  default     = []
}

variable "enable_public" {
  description = "If true, instances are launched in public subnets with a public IP assigned. If false, instances are launched in private subnets (tagged purpose:app) with no public IP."
  type        = bool
  default     = false
}

variable "public_subnets" {
  description = "List of public subnet IDs (one per AZ, e.g. eu-west-1a and eu-west-1b). Required when enable_public = true."
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet IDs tagged with purpose:app (one per AZ). Required when enable_public = false."
  type        = list(string)
  default     = []
}

variable "ami" {
  description = "AMI ID to use for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g., t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the instances"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Name of the EC2 key pair to use for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile to attach to the instances"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Type of the root EBS volume (gp2, gp3, io1, etc.)"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether the root EBS volume should be encrypted"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = null
}

variable "monitoring" {
  description = "Whether to enable detailed monitoring for the instances"
  type        = bool
  default     = false
}
