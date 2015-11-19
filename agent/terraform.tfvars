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

domain = "pcf-services.com"

vpc = "mongpdbaas-frankfurt"
vpc_key_name = "common-vpc-ssh-key"

#
# AWS Resource IDs created after 'server' has been terraformed 
#

vpc_id = "<Result of 'terraform output vpc_id' >"
az1_subnet_id = "<Result of 'terraform output az1_subnet_id'>"
az2_subnet_id = "<Result of 'terraform output az2_subnet_id'>"

#
# MongoDB
#

mongo_automation_agent = "mongodb-mms-automation-agent-manager-2.0.14.1398-1.x86_64.rpm"
number_automation_agents = "3"

# Group Id and Agent API key can be found in the 
# Ops Manager UI under Settings -> Group Settings
mongoops_group_id = "<Value of 'GROUP ID'>"
mongoops_agent_api_key = "<Value of 'AGENT API KEY'>"
