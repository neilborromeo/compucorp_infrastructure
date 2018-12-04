resource "aws_security_group" "sg_ssh_staging" {
    name = "${var.environment["prefix"]}_SG_COMPUCORP_ssh"
    vpc_id = "${aws_vpc.compucorp-staging-vpc.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [
          "222.127.56.111/32" # Neil's IP
        ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Environment = "${var.environment["name"]}"
        Name = "${var.environment["prefix"]}_SG_COMPUCORP_ssh"
    }
}

resource "aws_security_group" "sg_crm_staging" {
    name = "${var.environment["prefix"]}_SG_COMPUCORP_crm"
    vpc_id = "${aws_vpc.compucorp-staging-vpc.id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [
          "0.0.0.0/0"
          ] 
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Environment = "${var.environment["name"]}"
        Name = "${var.environment["prefix"]}_SG_COMPUCORP_crm"
    }
}
