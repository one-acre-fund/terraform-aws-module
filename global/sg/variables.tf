variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "application" {
  description = "Application / project name"
  type        = string
}

variable "cost_centre" {
  description = "Cost centre tag"
  type        = string
}

variable "owner" {
  description = "Owner tag"
  type        = string
}

variable "managed_by" {
  description = "Managed by tag"
  type        = string
}

variable "map_migrated" {
  description = "AWS map-migarted tag"
  type        = string
  default     = "migFM25HRY5PO"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

