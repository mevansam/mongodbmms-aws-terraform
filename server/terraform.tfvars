#
# AWS Access Keys
#
aws_access_key = "<Your AWS Access Key>"
aws_secret_key = "<Your AWS Secret Key>"

ssh_private_key_file = "<Path to the key to use to SSH into instances>"
ssh_public_key_file = "<Public key of the SSH key for the AWS key-pair>"

#
# VPC
#

domain = "<Your domain name maintained by AWS>"
hosted_zone_id = "<The hosted zone for the above domain>"

vpc = "mongpdbaas-frankfurt"
vpc_name = "MongoDBaaS"
vpc_long_name = "MongoDB as a Service"

vpc_key_name = "common-vpc-ssh-key"

#
# MongoDB
#

mongo_mms_email = "<Email address used by Mongo MMS to send alerts>"

mongo_mms = "mongodb-mms-1.8.2.312-1.x86_64.rpm"
mongo_mms_backup = "mongodb-mms-backup-daemon-1.8.2.312-1.x86_64.rpm"
