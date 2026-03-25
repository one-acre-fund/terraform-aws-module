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
  default     = "db.t3.medium"
}

variable "db_storage" {
  description = "Allocated storage in GB for the RDS instance"
  type        = number
  default     = 20
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
variable "s3_bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

##############################################
# EC2
##############################################
variable "ec2_instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "ec2_application_names" {
  description = "Per-instance name overrides (ec2-[app]-[env]-NN). Empty = use application for all."
  type        = list(string)
  default     = []
}

variable "ec2_enable_public" {
  description = "If true, launch instances in public subnets with a public IP. If false, use private app subnets."
  type        = bool
  default     = false
}

variable "ec2_ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_additional_volumes" {
  description = "Optional additional EBS volumes attached to every EC2 instance. Named vol-[app]-[env]-[N] with sequential numbering continuing from the root volume."
  type = list(object({
    device_name = string
    size        = number
    type        = optional(string, "gp3")
    encrypted   = optional(bool, true)
    iops        = optional(number, null)
    throughput  = optional(number, null)
  }))
  default = []
}