#
# MongoOps Server
#

resource "aws_security_group" "mongops-automation-agent" {

    name = "MongoOps Automation Agent"
    description = "Security group rules for MongoDB Operations Automation Agent"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = [ "${lookup(var.vpc, "cidr")}" ]
    }
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        cidr_blocks = [ "${lookup(var.vpc, "cidr")}" ]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = [ "${lookup(var.vpc, "cidr")}" ]
    }
    egress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

resource "aws_instance" "mongops-automation-agent-az1" {

    ami = "${lookup(var.amazon_amis, lookup(var.vpc, "region"))}"
    instance_type = "t2.medium"
    subnet_id = "${var.az1_subnet_id}"
    associate_public_ip_address = "true"
    security_groups = [ "${aws_security_group.mongops-automation-agent.id}" ]
    key_name = "${var.vpc_key_name}"

    root_block_device {
        volume_size = "20"
    }

    provisioner "remote-exec" {
        inline = [

            # Download the Ops Manager Automation Agent package.
            "curl -L http://mongodb-om.${var.domain}:8080/download/agent/automation/${var.mongo_automation_agent} -o mongodb-mms-automation-agent-manager.rpm",

            # Install the Ops Manager Automation Agent.
            "sudo rpm --install mongodb-mms-automation-agent-manager.rpm",

            # Configure the Ops Manager Automation Agent.
            "sudo sed -i \"s|mmsGroupId=.*|mmsGroupId=${var.mongoops_group_id}|\" /etc/mongodb-mms/automation-agent.config",
            "sudo sed -i \"s|mmsApiKey=.*|mmsApiKey=${var.mongoops_agent_api_key}|\" /etc/mongodb-mms/automation-agent.config",
            "sudo sed -i \"s|mmsBaseUrl=.*|mmsBaseUrl=http://mongodb-om.${var.domain}:8080|\" /etc/mongodb-mms/automation-agent.config",

            # Create the data directory for MongoDB instance
            "sudo mkdir /data",
            "sudo chown mongod:mongod /data",

            # Restart the service
            "sudo service mongodb-mms-automation-agent restart"
        ]
        connection {
            user = "ec2-user"
            key_file = "${var.ssh_private_key_file}"
        }
    }

    tags {
        Name = "MongoOps Automation Agent"
    }

    count = "${var.number_automation_agents / 2}"
}

resource "aws_instance" "mongops-automation-agent-az2" {

    ami = "${lookup(var.amazon_amis, lookup(var.vpc, "region"))}"
    instance_type = "t2.medium"
    subnet_id = "${var.az2_subnet_id}"
    associate_public_ip_address = "true"
    security_groups = [ "${aws_security_group.mongops-automation-agent.id}" ]
    key_name = "${var.vpc_key_name}"

    root_block_device {
        volume_size = "20"
    }

    provisioner "remote-exec" {
        inline = [

            # Download the Ops Manager Automation Agent package.
            "curl -L http://mongodb-om.${var.domain}:8080/download/agent/automation/${var.mongo_automation_agent} -o mongodb-mms-automation-agent-manager.rpm",

            # Install the Ops Manager Automation Agent.
            "sudo rpm --install mongodb-mms-automation-agent-manager.rpm",

            # Configure the Ops Manager Automation Agent.
            "sudo sed -i \"s|mmsGroupId=.*|mmsGroupId=${var.mongoops_group_id}|\" /etc/mongodb-mms/automation-agent.config",
            "sudo sed -i \"s|mmsApiKey=.*|mmsApiKey=${var.mongoops_agent_api_key}|\" /etc/mongodb-mms/automation-agent.config",
            "sudo sed -i \"s|mmsBaseUrl=.*|mmsBaseUrl=http://mongodb-om.${var.domain}:8080|\" /etc/mongodb-mms/automation-agent.config",

            # Create the data directory for MongoDB instance
            "sudo mkdir /data",
            "sudo chown mongod:mongod /data",
            
            # Restart the service
            "sudo service mongodb-mms-automation-agent restart"
        ]
        connection {
            user = "ec2-user"
            key_file = "${var.ssh_private_key_file}"
        }
    }

    tags {
        Name = "MongoOps Automation Agent"
    }

    count = "${var.number_automation_agents - (var.number_automation_agents / 2)}"
}
