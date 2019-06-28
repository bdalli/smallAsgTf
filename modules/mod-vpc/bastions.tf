
# Define bastion server inside the public subnet
resource "aws_instance" "bastion" {
  count                       = "${var.bastion_count}"
  ami                         = "${var.ami}"
  instance_type               = "t1.micro"
  key_name                    = "${var.bastion_key}"
  subnet_id                   = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.sgWeb.id}"]
  associate_public_ip_address = true

  source_dest_check = false


  tags = {
    Name = "${var.env_name}-bastion"
  }
}
