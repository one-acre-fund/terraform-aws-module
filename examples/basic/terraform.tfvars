##############################################
# Common
##############################################
region      = "eu-west-1"
environment = "dev"
application = "my-app"
cost_centre = "GLB-GR"
owner       = "platform-team"
managed_by  = "terraform"

##############################################
# VPC
##############################################
vpc_cidr               = "172.20.0.0/16"
azs                    = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs    = ["172.20.0.0/23", "172.20.2.0/23"]
private_subnet_cidrs   = ["172.20.10.0/22", "172.20.14.0/22"]
private_subnet_purpose = ["app", "db"]

##############################################
# Database
##############################################
db_engine         = "sqlserver-ee"
db_engine_version = "15.00.4312.2.v1"
db_instance_class = "db.t3.medium"
db_storage        = 20
db_username       = "rdsadmin"
db_license_model  = "license-included"

##############################################
# S3
##############################################
s3_bucket_name = "my-app-dev-data"

##############################################
# EC2
##############################################
# Creates 2 private instances spread across app subnets:
#   ec2-my-app-dev-01 → subnet eu-west-1a
#   ec2-my-app-dev-02 → subnet eu-west-1b
ec2_instance_count    = 2
ec2_application_names = []                      # leave empty to use var.application for all
ec2_enable_public     = false                   # place in private subnets tagged purpose:app
ec2_ami               = "ami-0d64bb532e0502c46" # Amazon Linux 2023 eu-west-1
ec2_instance_type     = "t3.micro"

# One 100 GB data volume attached to every instance:
#   vol-my-app-dev-01-data, vol-my-app-dev-02-data
ec2_additional_volumes = [
  {
    name_suffix = "data"
    device_name = "/dev/sdf"
    size        = 100
    type        = "gp3"
    encrypted   = true
  }
]