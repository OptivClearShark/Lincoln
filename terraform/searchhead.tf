resource "aws_instance" "searchhead" {
  ami                     = data.aws_ami.splunk_ami.id
  instance_type           = var.sh_instance_type
  subnet_id               = aws_subnet.private[0].id
  vpc_security_group_ids  = [aws_security_group.splunk_instance.id]
  iam_instance_profile    = aws_iam_instance_profile.ssm_profile.name
  monitoring              = var.enable_detailed_monitoring
  disable_api_termination = var.disable_api_termination

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    region   = var.aws_region
    hostname = "${var.project_name}-sh-01"
    username = lower(var.interviewee_fn)
    password = var.ssh_pw
  })

  metadata_options {
    http_tokens = var.require_imds_v2 ? "required" : "optional"
  }

  dynamic "credit_specification" {
    for_each = var.enable_t_instance_credit_spec ? [1] : []
    content {
      cpu_credits = var.t_instance_unlimited ? "unlimited" : "standard"
    }
  }

  tags = {
    Name = "${var.project_name}-${lower("${substr(var.interviewee_fn, 0, 1)}${substr(var.interviewee_ln, 0, 1)}")}-searchhead-01"
  }
}
