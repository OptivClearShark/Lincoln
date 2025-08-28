data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "splunk_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["al2023-splunk-${var.splunk_version}-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
