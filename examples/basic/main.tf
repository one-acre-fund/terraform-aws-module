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

  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  tags        = var.tags

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

  instance_name          = var.ec2_instance_name
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.ec2_sg.security_group_id]
  iam_instance_profile   = module.ec2_role.instance_profile_name

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
  description = "Security group ID for the EC2 instance"
  value       = module.ec2_sg.security_group_id
}

output "ec2_role_arn" {
  description = "IAM role ARN for the EC2 instance"
  value       = module.ec2_role.role_arn
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 instance private IP"
  value       = module.ec2.private_ip
}