# ---------------------------
# Common / Tagging Variables
# ---------------------------

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
# S3 Bucket Variables
# ---------------------------

variable "bucket_name" {
  description = "The globally unique name of the S3 bucket."
  type        = string
}

variable "force_destroy" {
  description = "Allow destroying the bucket even if it contains objects."
  type        = bool
  default     = false
}

# Versioning
variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket."
  type        = bool
  default     = true
}

# Server-side encryption
variable "sse_algorithm" {
  description = "Server-side encryption algorithm (aws:kms or AES256)."
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "KMS key ID or ARN used when sse_algorithm is aws:kms. Leave empty for AES256."
  type        = string
  default     = ""
}

# Public access block
variable "block_public_acls" {
  description = "Block public ACLs for the bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies for the bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs for the bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies for the bucket."
  type        = bool
  default     = true
}

variable "public_read_enabled" {
  description = "Attach a bucket policy granting public s3:GetObject to all objects. Requires all block_public_* variables to be false."
  type        = bool
  default     = false
}

# Lifecycle rules
variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rules to apply to the bucket.
    Each rule supports:
      id                         - Unique identifier for the rule.
      enabled                    - Whether the rule is enabled.
      prefix                     - Object key prefix to filter by (optional).
      expiration_days            - Days after which objects expire (optional).
      noncurrent_expiration_days - Days after which noncurrent versions expire (optional).
      transition_days            - Days after which objects transition to storage_class (optional).
      storage_class              - Target storage class for transitions (optional).
  EOT
  type = list(object({
    id                         = string
    enabled                    = bool
    prefix                     = optional(string, "")
    expiration_days            = optional(number, null)
    noncurrent_expiration_days = optional(number, null)
    transition_days            = optional(number, null)
    storage_class              = optional(string, null)
  }))
  default = []
}

# Logging
variable "logging_enabled" {
  description = "Enable server access logging for the bucket."
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Name of the S3 bucket to deliver access logs to. Required when logging_enabled is true."
  type        = string
  default     = ""
}

variable "logging_target_prefix" {
  description = "Prefix for log object keys."
  type        = string
  default     = "s3-access-logs/"
}

