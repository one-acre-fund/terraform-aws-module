##############################################
# Common
##############################################
region      = "eu-west-1"
environment = "prod"
application = "my-app"
cost_centre = "GLB-GR"
owner       = "platform-team"
managed_by  = "terraform"

tags = {
  Project = "my-app"
}

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