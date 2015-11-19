#
# AWS Connection
#

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${lookup(var.vpc, "region")}"
}
