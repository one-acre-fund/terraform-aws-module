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


# ---------------------------
# IAM Variables
# ---------------------------

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "JSON-encoded assume role (trust) policy document"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "create_policy" {
  description = "Whether to create a custom IAM policy and attach it to the role"
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "Name of the custom IAM policy"
  type        = string
  default     = ""
}

variable "policy_description" {
  description = "Description of the custom IAM policy"
  type        = string
  default     = ""
}

variable "policy_document" {
  description = "JSON-encoded IAM policy document for the custom policy"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "List of AWS managed or customer policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  description = "Whether to create an IAM instance profile associated with the role"
  type        = bool
  default     = false
}
