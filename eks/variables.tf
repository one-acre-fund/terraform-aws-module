# ---------------------------
# Common tags
# ---------------------------
variable "environment" {
  description = "Environment name (dev, qa, uat, prod)"
  type        = string
}

variable "application" {
  description = "The name of the owning application or service"
  type        = string
}

variable "cost_centre" {
  description = "The finance cost centre code or name (e.g., GLB-GR)"
  type        = string
}

variable "owner" {
  description = "The team or individual responsible for this resource"
  type        = string
}

variable "managed_by" {
  description = "Provisioning method (terraform/manual)"
  type        = string
  default     = "terraform"
}

variable "map_migrated" {
  description = "AWS map-migrated tag value"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}

# ---------------------------
# EKS Cluster
# ---------------------------
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN that the EKS control plane assumes"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster VPC config"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Additional security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of EKS control plane log types to enable (api, audit, authenticator, controllerManager, scheduler)"
  type        = list(string)
  default     = []
}

# ---------------------------
# Node Groups
# ---------------------------
variable "node_groups" {
  description = "Map of managed node groups to create. The map key is used as a logical identifier."
  type = map(object({
    node_group_name = string
    node_role_arn   = string
    subnet_ids      = list(string)
    instance_types  = optional(list(string), ["t3.medium"])
    ami_type        = optional(string, "AL2023_x86_64_STANDARD")
    capacity_type   = optional(string, "ON_DEMAND")
    min_size        = optional(number, 1)
    desired_size    = optional(number, 2)
    max_size        = optional(number, 4)
    labels          = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string, "")
      effect = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
