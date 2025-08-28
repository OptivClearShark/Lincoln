packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "splunk_version" {
  type    = string
  default = "9.4.4"
}

variable "splunk_wget_url" {
  type    = string
  default = "https://download.splunk.com/products/splunk/releases/9.4.4/linux/splunk-9.4.4-f627d88b766b-linux-amd64.tgz"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  date      = formatdate("YYYY.MM.DD - hhmm", timestamp())
  default_tags = {
    Name         = "AL2023-Splunk-${var.splunk_version}-${local.date}"
    TechnicalPOC = "Kevin Dorsey"
    Project      = "Lincoln"
    BuildDate    = timestamp()
    SourceAMI    = "{{ .SourceAMI }}"
    BuildRegion  = "{{ .BuildRegion }}"
  }
}

source "amazon-ebs" "al2023-splunk" {
  ami_name      = "al2023-splunk-${var.splunk_version}-${local.date}"
  instance_type = var.instance_type
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"

  tags            = local.default_tags
  snapshot_tags   = local.default_tags
  run_tags        = local.default_tags
  run_volume_tags = local.default_tags

  # Ensure 16 GB root volume on the build instance and resulting AMI
  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 32
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  ami_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 128
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

}

build {
  name = "splunk-enterprise"
  sources = [
    "source.amazon-ebs.al2023-splunk"
  ]

  # Run consolidated setup script
  provisioner "shell" {
    script = "scripts/splunk_setup.sh"
    environment_vars = [
      "SPLUNK_VERSION=${var.splunk_version}",
      "SPLUNK_WGET_URL=${var.splunk_wget_url}",
      "TIMEZONE=UTC"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
