##############################################
# Common
##############################################
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "application" {
  description = "Name of the owning application or service"
  type        = string
}

variable "cost_centre" {
  description = "Finance cost centre code or name"
  type        = string
}

variable "owner" {
  description = "Team or individual responsible for this resource"
  type        = string
}

variable "managed_by" {
  description = "Provisioning method (terraform/manual)"
  type        = string
  default     = "terraform"
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}

##############################################
# VPC
##############################################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "private_subnet_purpose" {
  description = "Purpose tag for each private subnet (must match order of private_subnet_cidrs)"
  type        = list(string)
  default     = []
}

variable "flow_logs_retention_days" {
  description = "CloudWatch log group retention in days for VPC flow logs"
  type        = number
  default     = 30
}

##############################################
# Database
##############################################
variable "db_engine" {
  description = "RDS database engine"
  type        = string
  default     = "sqlserver-ee"
}

variable "db_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.00.4312.2.v1"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r6i.large"
}

variable "db_storage" {
  description = "Allocated storage in GB for the RDS instance"
  type        = number
  default     = 100
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "rdsadmin"
}

variable "db_license_model" {
  description = "License model for the RDS engine"
  type        = string
  default     = "license-included"
}

##############################################
# S3
##############################################
variable "s3_buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    bucket_name        = string
    force_destroy      = optional(bool, false)
    versioning_enabled = optional(bool, true)
    sse_algorithm      = optional(string, "AES256")
  }))
  default = {}
}

##############################################
# EC2
##############################################
variable "ec2_instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ec2_ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ec2_root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 50
}