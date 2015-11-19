#
# MongoOps Server
#

resource "aws_security_group" "mongoops-server" {

    name = "MongoOps Server"
    description = "Security group rules for MongoDB Operations Manager server"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = "8080"
        to_port = "8080"
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        from_port = "8081"
        to_port = "8081"
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

resource "aws_instance" "mongoops-server" {

    ami = "${lookup(var.amazon_amis, lookup(var.vpc, "region"))}"
    instance_type = "m4.xlarge"
    subnet_id = "${aws_subnet.subnet-ext-az2.id}"
    associate_public_ip_address = "true"
    security_groups = [ "${aws_security_group.mongoops-server.id}" ]
    key_name = "${var.vpc_key_name}"

    root_block_device {
        volume_size = "50"
    }

    provisioner "remote-exec" {
        inline = [

            # Configure the yum package management system to install the latest stable release of MongoDB.
            "echo -e \"[MongoDB]\\nname=MongoDB Repository\\nbaseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64\ngpgcheck=0\\nenabled=1\" | sudo tee /etc/yum.repos.d/mongodb.repo",

            # Install MongoDB
            "sudo yum install -y mongodb-org mongodb-org-shell",

            # Create the data directory for the Ops Manager Application Database.
            "sudo mkdir -p /data/appdb",
            "sudo chown -R mongod:mongod /data",
            "sudo mkdir -p /data/backup",
            "sudo chown mongod:mongod /data/backup",

            # Download the Ops Manager Application package.
            "curl -L https://downloads.mongodb.com/on-prem-mms/rpm/${var.mongo_mms} -o mongo_mms.rpm",
            "curl -L https://downloads.mongodb.com/on-prem-mms/rpm/${var.mongo_mms_backup} -o mongo_mms_backup.rpm",

            # Install the Ops Manager Application.
            "sudo rpm --install mongo_mms.rpm",
            "sudo rpm --install mongo_mms_backup.rpm",

            # Get server’s public IP address.
            "export MY_IP=$(curl -s http://whatismijnip.nl |cut -d \" \" -f 5)",

            # Configure the Ops Manager Application.
            "sudo sed -i \"s|mms\\.centralUrl=.*|mms.centralUrl=http://$MY_IP:8080|\" /opt/mongodb/mms/conf/conf-mms.properties",
            "sudo sed -i \"s|mms\\.backupCentralUrl=.*|mms.backupCentralUrl=http://$MY_IP:8081|\" /opt/mongodb/mms/conf/conf-mms.properties",
            "sudo sed -i \"s|mms\\.\\(.*\\)EmailAddr=.*|mms.\\1EmailAddr=${var.mongo_mms_email}|g\" /opt/mongodb/mms/conf/conf-mms.properties",
            "sudo sed -i \"s|mongo\\.mongoUri=.*|mongo.mongoUri=mongodb://localhost:27017|\" /opt/mongodb/mms/conf/conf-mms.properties",
            "sudo sed -i \"s|mongo\\.mongoUri=.*|mongo.mongoUri=mongodb://localhost:27017|\" /opt/mongodb/mms-backup-daemon/conf/conf-daemon.properties",

            # Create startup script
            "echo -e \"sudo -u mongod mongod --port 27017 --dbpath /data/appdb --logpath /data/appdb/mongodb.log --fork\\nsudo -u mongod mongod --port 27018 --dbpath /data/backup --logpath /data/backup/mongodb.log --fork\\nsudo service mongodb-mms start\\nsudo service mongodb-mms-backup-daemon start\\n\" > ./start_mongoops.sh",
            "chmod 0744 ./start_mongoops.sh",
        ]
        connection {
            user = "ec2-user"
            key_file = "${var.ssh_private_key_file}"
        }
    }

    tags {
        Name = "MongoOps Server"
    }

    count = "1"
}

resource "aws_route53_record" "mongoops-server" {
   zone_id = "${var.hosted_zone_id}"
   name = "mongodb-om.${var.domain}"
   type = "A"
   ttl = "300"
   records = [ "${aws_instance.mongoops-server.public_ip}" ]
}
