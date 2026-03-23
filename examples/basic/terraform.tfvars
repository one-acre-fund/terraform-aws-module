##############################################
# Common
##############################################
region      = "eu-west-1"
environment = "dev"
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
azs                    = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs    = ["172.20.0.0/23", "172.20.2.0/23"]
private_subnet_cidrs   = ["172.20.10.0/22", "172.20.14.0/22"]
private_subnet_purpose = ["app", "db"]

##############################################
# Database
##############################################
db_engine          = "sqlserver-ee"
db_engine_version  = "15.00.4312.2.v1"
db_instance_class  = "db.t3.medium"
db_storage         = 20
db_username        = "rdsadmin"
db_license_model   = "license-included"