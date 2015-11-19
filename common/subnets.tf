#
# Create VPC subnets
#

resource "aws_subnet" "subnet-ext-az1" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${lookup(var.vpc, "az1")}"
    cidr_block = "${lookup(lookup(var.vpc, "az1"), "ext")}"

    tags {
        Name = "${var.vpc_name} - Subnet in AZ1 for MongoDB as a Service nodes"
    }
}

resource "aws_subnet" "subnet-ext-az2" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${lookup(var.vpc, "az2")}"
    cidr_block = "${lookup(lookup(var.vpc, "az2"), "ext")}"

    tags {
        Name = "${var.vpc_name} - Subnet in AZ2 for MongoDB as a Service nodes"
    }
}

resource "aws_route_table_association" "internet-route-az1" {
    subnet_id = "${aws_subnet.subnet-ext-az1.id}"
    route_table_id = "${aws_route_table.internet.id}"
}
resource "aws_route_table_association" "internet-route-az2" {
    subnet_id = "${aws_subnet.subnet-ext-az2.id}"
    route_table_id = "${aws_route_table.internet.id}"
}

#
# Outputs
#

output "az1_subnet_id" {
    value = "${aws_subnet.subnet-ext-az1.id}"
}
output "az2_subnet_id" {
    value = "${aws_subnet.subnet-ext-az2.id}"
}
