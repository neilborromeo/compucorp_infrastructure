resource "aws_instance" "compucorp_crm_01" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t1.micro"
    availability_zone = "${var.region}${var.az_1}"
    key_name = "${aws_key_pair.auth.id}"
    associate_public_ip_address = true
    root_block_device {
        delete_on_termination = "true"
    }
    tags {
        Name = "${var.environment["prefix"]}_CRM_web_1"
        Environment = "${var.environment["name"]}"
        hostname = "web01-stg"
        system = "web"
    }
    subnet_id = "${aws_subnet.compucorp-staging-ec2-subnet-1.id}"
    vpc_security_group_ids = [
      "${aws_security_group.sg_ssh_staging.id}",
      "${aws_security_group.sg_crm_staging.id}"
    ]
}
