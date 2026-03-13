# terraform-aws-vpc

A reusable VPC module with optional NAT gateways, flow logs, and tagging.

## Variables

| Name               | Description |
|--------------------|-------------|
| environment        | Environment name (dev/staging/prod). |
| application        | Owning application or service. |
| cost_centre        | Finance cost centre code. |
| owner              | Team or individual responsible. |
| vpc_cidr           | CIDR block for the VPC. |
| azs                | List of availability zones. |
| public_subnet_cidrs| CIDR blocks for public subnets. |
| private_subnet_cidrs| CIDR blocks for private subnets. |
| enable_dns_hostnames| Enable DNS hostnames (bool). |
| enable_dns_support | Enable DNS support (bool). |
| enable_nat_gateway | Provision NAT gateways (bool). |
| single_nat_gateway | Use single NAT gateway (bool). |
| create_igw         | Create internet gateway (bool). |
| enable_flow_logs   | Enable VPC flow logs (bool). |
| flow_logs_retention_days | CloudWatch log retention. |
| tags               | Additional tags map. |

