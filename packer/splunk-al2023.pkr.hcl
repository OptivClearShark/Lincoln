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

}

build {
  name = "splunk-enterprise"
  sources = [
    "source.amazon-ebs.al2023-splunk"
  ]

  # Set timezone to UTC
  provisioner "shell" {
    inline = [
      "sudo timedatectl set-timezone UTC"
    ]
  }

  # Update system and install prerequisites
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y wget unzip",
      "echo 'System updated and prerequisites installed'"
    ]
  }

  # Install and configure SSM agent
  provisioner "shell" {
    inline = [
      "echo 'Installing SSM Agent...'",
      "sudo dnf install -y amazon-ssm-agent",
      "sudo systemctl enable amazon-ssm-agent",
      "sudo systemctl start amazon-ssm-agent",
      "echo 'SSM Agent installed and enabled'"
    ]
  }

  # Create splunk user and directories
  #provisioner "shell" {
  #  inline = [
  #    "echo 'Creating splunk user and directories...'",
  #    "sudo useradd -r -m -U -d /opt/splunk -s /bin/bash splunk",
  #    "sudo mkdir -p /opt/splunk",
  #    "sudo chown splunk:splunk /opt/splunk"
  #  ]
  #}

  # Download and install Splunk Enterprise
  #provisioner "shell" {
  #  inline = [
  #    "echo 'Downloading Splunk Enterprise ${var.splunk_version}...'",
  #    "cd /tmp",
  #    "wget -O splunk.tgz \"${var.splunk_wget_url}",
  #    "echo 'Extracting Splunk Enterprise...'",
  #    "sudo tar -xzf splunk.tgz -C /opt/",
  #    "sudo chown -R splunk:splunk /opt/splunk",
  #    "rm -f /tmp/splunk.tgz"
  #  ]
  #}

  # Configure Splunk initial setup
  #provisioner "shell" {
  #  inline = [
  #    "echo 'Configuring Splunk Enterprise...'",
  #    "sudo -u splunk /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd changeme123",
  #    "sudo -u splunk /opt/splunk/bin/splunk stop",
  #    "echo 'Initial Splunk setup completed'"
  #  ]
  #}

  # Create systemd service for Splunk
  #provisioner "shell" {
  #  inline = [
  #    "echo 'Creating systemd service for Splunk...'",
  #    "sudo /opt/splunk/bin/splunk enable boot-start -user splunk --accept-license",
  #    "echo 'Splunk systemd service created'"
  #  ]
  #}

  # Configure firewall for Splunk ports
  #provisioner "shell" {
  #  inline = [
  #    "echo 'Configuring firewall for Splunk ports...'",
  #    "sudo firewall-cmd --permanent --add-port=8000/tcp",
  #    "sudo firewall-cmd --permanent --add-port=8089/tcp",
  #    "sudo firewall-cmd --permanent --add-port=9997/tcp",
  #    "sudo firewall-cmd --reload",
  #    "echo 'Firewall configured for Splunk'"
  #  ]
  #}

  # Create startup script for SSM session connectivity
  #provisioner "shell" {
  #  inline = [
  #    "echo 'Creating SSM connectivity script...'",
  #    "cat << 'EOF' | sudo tee /opt/ssm-setup.sh",
  #    "#!/bin/bash",
  #    "# Ensure SSM agent is running",
  #    "systemctl start amazon-ssm-agent",
  #    "systemctl enable amazon-ssm-agent",
  #    "",
  #    "# Set up session manager plugin prerequisites",
  #    "echo 'SSM Agent Status:'",
  #    "systemctl status amazon-ssm-agent --no-pager",
  #    "EOF",
  #    "sudo chmod +x /opt/ssm-setup.sh"
  #  ]
  #}

  # Final system cleanup and optimization
  provisioner "shell" {
    inline = [
      "echo 'Performing final system cleanup...'",
      "sudo dnf clean all",
      "sudo rm -rf /var/cache/dnf/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "history -c",
      "echo 'System cleanup completed'"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}