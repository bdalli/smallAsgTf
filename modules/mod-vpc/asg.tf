# asg launch config and autoscaling group

resource "aws_launch_configuration" "smallAsg_launch_config" {

  image_id      = "${var.ami}"
  instance_type = "t2.micro"

  security_groups             = ["${aws_security_group.sgWeb.id}"]
  associate_public_ip_address = false


  user_data = <<-EOF
    #!/bin/bash
    echo "Hello I am part of a smallAsg" > index.html
    nohup busybox httpd -f -p 80 &
    EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "smallAsg_asg" {
  count = "${var.aws_az_count}"
  launch_configuration = "${aws_launch_configuration.smallAsg_launch_config.id}"
  #availability_zones = "${var.aws_az}"
  vpc_zone_identifier = ["${element(aws_subnet.public-subnet.*.id, count.index)}"]

  load_balancers = ["${aws_elb.smallAsg_lb.name}"]
  health_check_type = "ELB"
  health_check_grace_period = "300"

  min_size = 1
  max_size = 3

  tag {

    key = "Name"
    value = "${var.env_name}-smallAsg-ec2"
    propagate_at_launch = true
  }
}

# smallAsg Loab Balancer

resource "aws_elb" "smallAsg_lb" {
  name = "smallAsgELB"
  #count = "${var.aws_az_count}"
  #availability_zones = "${var.aws_az}"
  subnets = "${aws_subnet.public-subnet.*.id}"
  security_groups = ["${aws_security_group.smallAsgElbSg.id}"]

  listener {

    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"

  }
}



# resource "aws_instance" "smallAsgInstance" {
#   count = "${var.bastion_count}"
#   ami = "${var.ami}"
#   instance_type = "t1.micro"
#   #key_name                    = "${var.bastion_key}"
#   subnet_id = "${element(aws_subnet.public-subnet.*.id, count.index)}"
#   vpc_security_group_ids = ["${aws_security_group.sgWeb.id}"]
#   associate_public_ip_address = true

#   source_dest_check = false


#   tags = {
#     Name = "${var.env_name}-smallAsg-ec2"
#   }
# }
