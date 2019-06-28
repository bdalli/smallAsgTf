# Define the public subnet
resource "aws_subnet" "public-subnet" {
  count             = "${var.aws_az_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_subnet_cidr[count.index]}"
  availability_zone = "${var.aws_az[count.index]}"

  tags = {
    Name = "${var.env_name}-public-subnet"
  }
}

# Define the private subnet
resource "aws_subnet" "app-subnet" {
  count             = "${var.aws_az_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.app_subnet_cidr[count.index]}"
  availability_zone = "${var.aws_az[count.index]}"

  tags = {
    Name = "${var.env_name}-appServs-subnet"
  }
}
