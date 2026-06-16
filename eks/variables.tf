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
# EKS Cluster — Core
# ---------------------------
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster (e.g. 1.33)"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN that the EKS control plane assumes"
  type        = string
}

variable "deletion_protection" {
  description = "Enable deletion protection on the EKS cluster"
  type        = bool
  default     = true
}

variable "bootstrap_self_managed_addons" {
  description = "Whether to bootstrap self-managed addons after cluster creation"
  type        = bool
  default     = true
}

# ---------------------------
# EKS Cluster — Networking
# ---------------------------
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

# ---------------------------
# EKS Cluster — Kubernetes Network Config
# NOTE: These are set at cluster creation and cannot be changed after.
# Leave as null to use AWS defaults.
# ---------------------------
variable "ip_family" {
  description = "IP family for the cluster (ipv4 or ipv6)"
  type        = string
  default     = null
}

variable "service_ipv4_cidr" {
  description = "CIDR block for Kubernetes service IPs (e.g. 10.100.0.0/16). Set at creation only."
  type        = string
  default     = null
}

variable "elastic_load_balancing_enabled" {
  description = "Enable native VPC Load Balancing controller"
  type        = bool
  default     = false
}

# ---------------------------
# EKS Cluster — Logging
# ---------------------------
variable "enabled_cluster_log_types" {
  description = "Control plane log types: api, audit, authenticator, controllerManager, scheduler"
  type        = list(string)
  default     = []
}

# ---------------------------
# EKS Cluster — Access Config
# ---------------------------
variable "authentication_mode" {
  description = "Authentication mode for the cluster: CONFIG_MAP, API, or API_AND_CONFIG_MAP"
  type        = string
  default     = "API"
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant cluster-admin permissions to the IAM principal creating the cluster"
  type        = bool
  default     = true
}

# ---------------------------
# EKS Cluster — Upgrade Policy
# ---------------------------
variable "support_type" {
  description = "Cluster support type: STANDARD or EXTENDED"
  type        = string
  default     = "STANDARD"
}

# ---------------------------
# EKS Cluster — Control Plane Scaling
# ---------------------------
variable "control_plane_scaling_tier" {
  description = "Control plane scaling tier: standard or premium"
  type        = string
  default     = "standard"
}

# ---------------------------
# EKS Cluster — Add-ons
# ---------------------------
variable "cluster_addons" {
  description = "Map of EKS add-ons to install. Key is add-on name (e.g. vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver)."
  type = map(object({
    addon_version               = optional(string, null) # null = latest
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string, null)
    configuration_values        = optional(string, null) # JSON string
    preserve                    = optional(bool, false)
  }))
  default = {}
}

# ---------------------------
# Node Groups
# ---------------------------
variable "node_groups" {
  description = "Map of managed node groups. The map key is used as a logical identifier."
  type = map(object({
    node_group_name = string
    node_role_arn   = string
    subnet_ids      = list(string)

    # Instance config
    instance_types = optional(list(string), ["t3.medium"])
    ami_type       = optional(string, "AL2023_x86_64_STANDARD")
    ami_release_version = optional(string, null) # null = latest for the k8s version
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, null) # GB; null = AWS default (20)

    # Scaling
    min_size     = optional(number, 1)
    desired_size = optional(number, 2)
    max_size     = optional(number, 4)

    # Update config
    max_unavailable            = optional(number, 1)
    max_unavailable_percentage = optional(number, null) # mutually exclusive with max_unavailable

    # Node repair
    node_repair_enabled = optional(bool, false)

    # Labels & taints
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string, "")
      effect = string # NO_SCHEDULE | NO_EXECUTE | PREFER_NO_SCHEDULE
    })), [])

    # Remote access (optional)
    ec2_ssh_key               = optional(string, null)
    source_security_group_ids = optional(list(string), [])

    tags = optional(map(string), {})
  }))
  default = {}
}
