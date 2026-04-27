variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "application" {
  description = "The name of the owning application or service (e.g., odoo, fineract)."
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
  description = "AWS map-migarted tag"
  type        = string
  default     = "migFM25HRY5PO"
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}



#Database variables
variable "apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = false
}

variable "db_name" {
  description = ""
  type        = string
  default     = ""
}

variable "max_allocated_storage" {
  description = "The maximum allocated storage for the RDS instance (in GiB)"
  type        = number
  default     = 1000
}

variable "multi_az_enabled" {
  description = "Whether to enable Multi-AZ for the RDS instance"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups. Must be >= 1 when multi_az_enabled is true."
  type        = number
  default     = 0
}

variable "engine" {
  description = "The type of database engine (sqlserver-ee or postgres)"
  type        = string
  default     = "sqlserver-ee" # Default to SQL Server Enterprise Edition
  validation {
    condition     = contains(["sqlserver-ee", "postgres"], var.engine)
    error_message = "Engine must be one of: sqlserver-ee, postgres."
  }
}


variable "engine_version" {
  description = "Engine version for the RDS instance (e.g. 15.00.4455.2.v1 for sqlserver-ee, 16.10 for postgres)"
  type        = string
}
variable "username" {
  description = ""
  type        = string
  default     = "rdsadmin"
}

variable "instance_class" {
  description = ""
  type        = string
  default     = "db.t3.micro"
}
variable "deletion_protection" {
  description = "Whether to enable deletion protection for the RDS instance"
  type        = bool
  default     = true
}

# variable "subnet_ids" {
#   description = ""
#   type        = list(string)
#   default     = ["subnet-0962fa78f6c20fcc0", "subnet-0b6393167ed9e2e0f"]

# }

variable "db_identifier" {
  description = ""
  default     = "oafbackoffice-dev-01"
  type        = string

}

variable "storage" {
  description = "Allocated storage in GiB"
  default     = 20
  type        = number
}

variable "storage_type" {
  description = "Storage type for the RDS instance (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "db_subnet_group_name" {
  description = ""
  type        = string
  default     = "oafbackoffice-dev-subnet-group"
}

variable "license_model" {
  description = ""
  type        = string
  default     = "license-included"

}

variable "skip_final_snapshot" {
  description = ""
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = ""
  type        = bool
  default     = false
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to assign to the RDS instance"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "ARN of the KMS key to use for RDS storage encryption and Secrets Manager. Leave empty to use the AWS-managed key."
  type        = string
  default     = ""
}


variable "parameter_group_family" {
  description = "DB parameter group family (e.g. sqlserver-ee-15.0, postgres14, postgres16)"
  type        = string
  default     = ""
}

variable "db_parameters" {
  description = "List of DB parameters to set in the parameter group"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 to disable, valid values: 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}