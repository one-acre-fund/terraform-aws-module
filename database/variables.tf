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

variable "engine" {
  description = ""
  type        = string
  default     = "sqlserver-ee"
}
variable "engine_version" {
  description = ""
  type        = string
  default     = "15.00.4312.2.v1"
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

variable "subnet_ids" {
  description = ""
  type        = list(string)
  default     = ["subnet-0962fa78f6c20fcc0", "subnet-0b6393167ed9e2e0f"]

}

variable "db_identifier" {
  description = ""
  default     = "oafbackoffice-dev-01"
  type        = string

}

variable "storage" {
  description = ""
  default     = 20
  type        = number

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

variable "manage_master_user_password" {
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