# ==== VPC ====
# Create a VPC to launch our instances into
resource "aws_vpc" "compucorp-staging-vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "compucorp-staging-vpc"
    Environment = "${var.environment["name"]}"
  }
}

# ==== INTERNET GATEWAY ====
# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "compucorp-staging-ig" {
  vpc_id = "${aws_vpc.compucorp-staging-vpc.id}"
  tags {
    Name = "compucorp-staging-ig"
    Environment = "${var.environment["name"]}"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.compucorp-staging-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.compucorp-staging-ig.id}"
}

# ==== KEY PAIRS ====
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
