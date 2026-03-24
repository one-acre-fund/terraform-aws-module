##############################################
# Common
##############################################
region      = "eu-west-1"
environment = "prod"
application = "my-app"
cost_centre = "GLB-GR"
owner       = "platform-team"
managed_by  = "terraform"

##############################################
# VPC
##############################################
vpc_cidr               = "172.20.0.0/16"
azs                    = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
public_subnet_cidrs    = ["172.20.0.0/23", "172.20.2.0/23", "172.20.4.0/23"]
private_subnet_cidrs   = ["172.20.10.0/22", "172.20.14.0/22", "172.20.18.0/22"]
private_subnet_purpose = ["app", "app", "db"] # must match number of private_subnet_cidrs

flow_logs_retention_days = 90

##############################################
# Database
##############################################
db_engine         = "sqlserver-ee"
db_engine_version = "15.00.4312.2.v1"
db_instance_class = "db.r6i.large"
db_storage        = 100
db_username       = "rdsadmin"
db_license_model  = "license-included"

##############################################
# S3
##############################################
s3_buckets = {
  app-data = {
    bucket_name        = "my-app-prod-data"
    force_destroy      = false
    versioning_enabled = true
    sse_algorithm      = "AES256"
  }
  app-logs = {
    bucket_name        = "my-app-prod-logs"
    force_destroy      = false
    versioning_enabled = false
    sse_algorithm      = "AES256"
  }
}

##############################################
# EC2
##############################################
ec2_instance_name    = "my-app-prod-ec2"
ec2_ami              = "ami-0d64bb532e0502c46" # Amazon Linux 2023 eu-west-1
ec2_instance_type    = "t3.small"
ec2_root_volume_size = 50