# terraform-aws-module

Reusable Terraform modules for provisioning core AWS infrastructure components with consistent tagging, naming conventions, and security defaults across environments.

---

## Modules

| Module | Path | Description |
|--------|------|-------------|
| VPC | [`vpc/`](./vpc) | VPC, public/private subnets, Internet Gateway, NAT Gateways, route tables, and VPC Flow Logs |
| Security Group | [`global/sg/`](./global/sg) | Security Group with configurable dynamic ingress and egress rules |
| Database | [`database/`](./database) | RDS instance with DB subnet group |

---

## Folder Structure

> Auto-updated on every push by the `Update Docs` GitHub Actions workflow.

<!-- BEGIN_FOLDER_STRUCTURE -->
```
.
├── database
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── ec2
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── elasticbeanstalk
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── examples
│   ├── basic
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── complete
│       ├── main.tf
│       ├── terraform.tfvars
│       └── variables.tf
├── global
│   ├── iam
│   │   ├── locals.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── sg
│       ├── locals.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── versions.tf
├── s3
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── vpc
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── CHANGELOG.md
└── README.md

12 directories, 43 files
```
<!-- END_FOLDER_STRUCTURE -->

---

## Usage

### Basic Example

Minimal single-NAT VPC + Security Group + RDS — suitable for development environments:

```hcl
module "vpc" {
  source = "git::https://github.com/one-acre-fund/terraform-aws-module.git//vpc"

  environment = "dev"
  application = "my-app"
  cost_centre = "GLB-GR"
  owner       = "platform-team"
  managed_by  = "terraform"

  vpc_cidr             = "172.20.0.0/16"
  azs                  = ["eu-west-1a", "eu-west-1b"]
  public_subnet_cidrs  = ["172.20.0.0/23", "172.20.2.0/23"]
  private_subnet_cidrs = ["172.20.10.0/22", "172.20.14.0/22"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "rds_sg" {
  source = "git::https://github.com/one-acre-fund/terraform-aws-module.git//global/sg"

  name        = "my-app-dev-rds-sg"
  description = "Allow SQL Server traffic from private subnets"
  vpc_id      = module.vpc.vpc_id

  environment = "dev"
  application = "my-app"
  cost_centre = "GLB-GR"
  owner       = "platform-team"
  managed_by  = "terraform"

  ingress_rules = [
    {
      from_port   = 1433
      to_port     = 1433
      protocol    = "tcp"
      cidr_blocks = ["172.20.10.0/22", "172.20.14.0/22"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "database" {
  source = "git::https://github.com/one-acre-fund/terraform-aws-module.git//database"

  environment = "dev"
  application = "my-app"
  cost_centre = "GLB-GR"
  owner       = "platform-team"
  managed_by  = "terraform"

  db_identifier        = "my-app-dev-db"
  db_subnet_group_name = "my-app-dev-subnet-grp"
  subnet_ids           = module.vpc.private_subnet_ids

  vpc_security_group_ids      = [module.rds_sg.security_group_id]
  manage_master_user_password = true
  skip_final_snapshot         = true
}
```

See [`examples/basic`](./examples/basic) for a full single-environment deployment and [`examples/complete`](./examples/complete) for a production-ready multi-AZ setup with all modules, VPC Flow Logs, and per-AZ NAT Gateways.

---

## Requirements

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
Version 1.7.0
Version 1.8.0
Version 1.8.1
Version 1.8.2
Version 1.8.3
Version 1.8.4
Version 1.8.5
Version 1.8.6
Version 1.8.7
Version 1.8.8
Version 1.8.9
Version 1.8.10
Version 1.8.11
Version 1.8.12
Version 1.8.13
Version 1.8.14
Version 1.8.15
Version 1.8.16
Version 1.8.17
Version 1.8.18
Version 1.8.19
Version 1.8.20
Version 1.8.21
Version 1.8.22
Version 1.8.23
Version 1.8.24
Version 1.8.25
Version 1.8.26
Version 1.9.0
Version 1.9.1
Version 1.9.2
Version 1.9.3
Version 1.9.4
