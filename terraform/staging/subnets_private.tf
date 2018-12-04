resource "aws_subnet" "compucorp-staging-ec2-subnet-1" {
  vpc_id                  = "${aws_vpc.compucorp-staging-vpc.id}"
  availability_zone       = "${var.region}${var.az_1}"
  cidr_block              = "172.16.10.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "compucorp-staging-ec2-subnet-1"
    Environment = "${var.environment["name"]}"
  }
}
