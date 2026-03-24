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
# EC2 Variables
# ---------------------------

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g., t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID in which to launch the EC2 instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Name of the EC2 key pair to use for SSH access"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "Name of the IAM instance profile to attach to the instance"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}

variable "root_volume_name" {
  description = "Name tag for the root EBS volume"
  type        = string
  default     = null
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
  description = "Whether to enable detailed monitoring for the instance"
  type        = bool
  default     = false
}
