#
# Create VPC
#

resource "aws_vpc" "vpc" {
    cidr_block = "${lookup(var.vpc, "cidr")}"
    enable_dns_hostnames = true

    tags {
        Name = "${var.vpc_name}"
    }
}

#
# Associate VPC internet gateway
#

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.vpc.id}"
}
resource "aws_route_table" "internet" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
        Name = "${var.vpc_name} - internet"
    }
}

#
# Key pair to use for all instances in VPC
#

resource "aws_key_pair" "common-vpc" {
    key_name = "${var.vpc_key_name}"
    public_key = "${file(var.ssh_public_key_file)}"
}

#
# Outputs
#

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}
