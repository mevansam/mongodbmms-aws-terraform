#
# Common Externalized Variables
#

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "ssh_private_key_file" {}
variable "ssh_public_key_file" {}

variable "domain" {}

variable "vpc" {}
variable "vpc_key_name" {}

#
# Ubuntu AMIs mapped to AWS regions
#

variable "amazon_amis" {
    default = {
        us-west-1 = "ami-d5ea86b5"
        us-west-2 = "ami-f0091d91"
        us-east-1 = "ami-60b6c60a"
        eu-west-1 = "ami-bff32ccc"
        eu-central-1 = "ami-bc5b48d0"
        ap-southeast-1 = "ami-c9b572aa"
        ap-southeast-2 = "ami-48d38c2b"
        ap-northeast-1 = "ami-383c1956"
        sa-east-1 = "ami-6817af04"
    }
}

#
# VPC
#

variable "mongpdbaas-frankfurt" {
    default = {
        cidr = "10.0.0.0/16"
        region = "eu-central-1"
        az1 = "eu-central-1a"
        az2 = "eu-central-1b"
    }
}

#
# VPC subnets
#

variable "eu-central-1a" {
    default = {
        ext = "10.0.0.0/20"
    }
}
variable "eu-central-1b" {
    default = {
        ext = "10.0.16.0/20"
    }
}
