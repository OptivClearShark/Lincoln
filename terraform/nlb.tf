resource "aws_lb" "splunk_nlb" {
  name                             = "${var.project_name}-splunk-nlb"
  load_balancer_type               = "network"
  internal                         = false
  subnets                          = aws_subnet.public[*].id
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_name}-splunk-nlb"
  }
}

resource "aws_lb_target_group" "ssh" {
  name        = "${var.project_name}-ssh"
  port        = 22
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "22"
  }

  tags = {
    Name = "${var.project_name}-ssh-tg"
  }
}

resource "aws_lb_target_group" "splunk_web" {
  name        = "${var.project_name}-splunk-web"
  port        = 8000
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "8000"
  }

  tags = {
    Name = "${var.project_name}-splunk-web-tg"
  }
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.splunk_nlb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssh.arn
  }
}

resource "aws_lb_listener" "splunk_web" {
  load_balancer_arn = aws_lb.splunk_nlb.arn
  port              = 8000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.splunk_web.arn
  }
}

resource "aws_lb_target_group_attachment" "ssh" {
  target_group_arn = aws_lb_target_group.ssh.arn
  target_id        = aws_instance.searchhead.id
  port             = 22
  depends_on       = [aws_instance.searchhead]
}

resource "aws_lb_target_group_attachment" "splunk_web" {
  target_group_arn = aws_lb_target_group.splunk_web.arn
  target_id        = aws_instance.searchhead.id
  port             = 8000
  depends_on       = [aws_instance.searchhead]
}
