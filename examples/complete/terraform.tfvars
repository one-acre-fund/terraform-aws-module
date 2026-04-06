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
# Creates 4 private instances spread alternately across 2 app subnets (AZs):
#   ec2-my-app-prod-01 → eu-west-1a
#   ec2-my-app-prod-02 → eu-west-1b
#   ec2-my-app-prod-03 → eu-west-1a
#   ec2-my-app-prod-04 → eu-west-1b
ec2_instance_count    = 4
ec2_application_names = []                      # leave empty to use var.application for all
ec2_enable_public     = false                   # place in private subnets tagged purpose:app
ec2_ami               = "ami-0d64bb532e0502c46" # Amazon Linux 2023 eu-west-1
ec2_instance_type     = "t3.small"
ec2_root_volume_size  = 50
ec2_monitoring        = true

# Two additional volumes per instance (sequential naming continues from root):
#   ec2-my-app-prod-01 → vol-my-app-prod-01 (root), vol-my-app-prod-02, vol-my-app-prod-03
#   ec2-my-app-prod-02 → vol-my-app-prod-04 (root), vol-my-app-prod-05, vol-my-app-prod-06
#   ec2-my-app-prod-03 → vol-my-app-prod-07 (root), vol-my-app-prod-08, vol-my-app-prod-09
#   ec2-my-app-prod-04 → vol-my-app-prod-10 (root), vol-my-app-prod-11, vol-my-app-prod-12
ec2_additional_volumes = [
  {
    device_name = "/dev/sdf"
    size        = 200
    type        = "gp3"
    encrypted   = true
    throughput  = 150
  },
  {
    device_name = "/dev/sdg"
    size        = 50
    type        = "gp3"
    encrypted   = true
  }
]

##############################################
# Elastic Beanstalk
# app:   elasticbeanstalk-my-app-prod
# env:   elasticbeanstalk-env-my-app-prod
# cname: my-app-prod.eu-west-1.elasticbeanstalk.com
##############################################
eb_solution_stack_name = "64bit Amazon Linux 2023 v4.3.0 running Python 3.11"
eb_instance_type       = "t3.medium"
eb_min_instances       = 2
eb_max_instances       = 4
eb_certificate_arn     = "" # replace with your ACM certificate ARN