terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  # Private subnets tagged purpose:app — passed to the EC2 module
  ec2_app_private_subnets = [
    for i, purpose in var.private_subnet_purpose :
    module.vpc.private_subnet_ids[i]
    if purpose == "app"
  ]
}

##############################################
# VPC
##############################################
module "vpc" {
  source = "../../vpc"

  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  vpc_cidr    = var.vpc_cidr

  azs                    = var.azs
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  private_subnet_purpose = var.private_subnet_purpose

  enable_nat_gateway = true
  single_nat_gateway = true # single NAT to save cost in dev/basic environments

  tags = var.tags
}

##############################################
# Security Group — RDS
##############################################
module "rds_sg" {
  source = "../../global/sg"

  name        = "${var.application}-${var.environment}-rds-sg"
  description = "Allow inbound database traffic to the RDS instance"
  vpc_id      = module.vpc.vpc_id

  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  tags        = var.tags

  ingress_rules = [
    {
      description = "SQL Server from private subnets"
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      cidr_blocks = var.private_subnet_cidrs
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

##############################################
# Database — RDS
##############################################
module "database" {
  source = "../../database"

  environment          = var.environment
  application          = var.application
  cost_centre          = var.cost_centre
  owner                = var.owner
  managed_by           = var.managed_by
  tags                 = var.tags
  db_name              = var.db_engine == "postgres" ? var.db_name : null
  db_identifier        = "${var.application}-${var.environment}-db"
  db_subnet_group_name = "${var.application}-${var.environment}-subnet-grp"
  subnet_ids           = module.vpc.private_subnet_ids

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  storage        = var.db_storage
  username       = var.db_username
  license_model  = var.db_license_model

  vpc_security_group_ids      = [module.rds_sg.security_group_id]
  manage_master_user_password = true
  skip_final_snapshot         = true
  publicly_accessible         = false

  depends_on = [module.vpc]
}

##############################################
# S3 — Application bucket
##############################################
module "s3" {
  source = "../../s3"

  bucket_name        = var.s3_bucket_name
  force_destroy      = true
  versioning_enabled = true
  sse_algorithm      = "AES256"

  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  tags        = var.tags
}

##############################################
# Security Group — EC2
##############################################
module "ec2_sg" {
  source = "../../global/sg"

  name        = "${var.application}-${var.environment}-ec2-sg"
  description = "Allow SSH access to the EC2 instance from private subnets"
  vpc_id      = module.vpc.vpc_id

  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  tags        = var.tags

  ingress_rules = [
    {
      description = "SSH from private subnets"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.private_subnet_cidrs
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

##############################################
# IAM — EC2 instance role
##############################################
module "ec2_role" {
  source = "../../global/iam"

  role_name        = "${var.application}-${var.environment}-ec2-role"
  role_description = "IAM role for the EC2 instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  create_instance_profile = true

  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  tags        = var.tags
}

##############################################
# EC2 — Application instance
##############################################
module "ec2" {
  source = "../../ec2"

  # Count & naming
  instance_count    = var.ec2_instance_count
  application_names = var.ec2_application_names

  # Placement: false = private app subnets, true = public subnets
  enable_public   = var.ec2_enable_public
  enable_eip      = var.ec2_enable_eip
  private_subnets = local.ec2_app_private_subnets
  public_subnets  = module.vpc.public_subnet_ids

  # Instance
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [module.ec2_sg.security_group_id]
  iam_instance_profile   = module.ec2_role.instance_profile_name

  # Storage
  root_volume_encrypted = true
  additional_volumes    = var.ec2_additional_volumes

  # Common
  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  tags        = var.tags

  depends_on = [module.vpc]
}

##############################################
# Outputs
##############################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_gateway_public_ips
}

output "ec2_elastic_ips" {
  description = "Elastic IPs allocated to EC2 instances (empty if enable_eip = false)"
  value       = module.ec2.elastic_ips
}

output "rds_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = module.rds_sg.security_group_id
}

output "rds_security_group_arn" {
  description = "Security group ARN for the RDS instance"
  value       = module.rds_sg.security_group_arn
}

output "database_instance_name" {
  description = "RDS instance DB name"
  value       = module.database.aws_db_instance
}

output "s3_bucket_id" {
  description = "S3 bucket name"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "ec2_security_group_id" {
  description = "Security group ID for the EC2 instances"
  value       = module.ec2_sg.security_group_id
}

output "ec2_role_arn" {
  description = "IAM role ARN for the EC2 instances"
  value       = module.ec2_role.role_arn
}

output "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "ec2_instance_names" {
  description = "List of EC2 instance names (ec2-[app]-[env]-NN)"
  value       = module.ec2.instance_names
}

output "ec2_private_ips" {
  description = "List of private IP addresses of the EC2 instances"
  value       = module.ec2.private_ips
}

output "ec2_subnet_assignments" {
  description = "Map of instance name to subnet showing alternating distribution"
  value       = module.ec2.subnet_assignments
}

output "ec2_additional_volume_ids" {
  description = "Map of volume key (e.g. '01-data') to EBS volume ID for additional volumes"
  value       = module.ec2.additional_volume_ids
}