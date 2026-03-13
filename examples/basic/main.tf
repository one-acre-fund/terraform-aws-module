provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../.."

  environment = var.environment
  application = var.application
  cost_centre = var.cost_centre
  owner       = var.owner
  managed_by  = var.managed_by
  vpc_cidr    = var.vpc_cidr

  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "my-app"
    Owner   = "platform-team"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}