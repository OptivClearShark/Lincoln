#!/bin/bash

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script execution at $(date)"

# Set hostname from template input if provided
HOSTNAME_TO_SET="${hostname}"
if [ -n "$HOSTNAME_TO_SET" ]; then
  echo "Setting hostname to $HOSTNAME_TO_SET"
  hostnamectl set-hostname "$HOSTNAME_TO_SET"
fi

# Ensure SSM agent is running (should already be installed via Packer)
echo "Ensuring SSM agent is running..."
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

# Wait for SSM agent to be ready
echo "Waiting for SSM agent to be ready..."
sleep 30

# Check SSM agent status
echo "SSM Agent status:"
systemctl status amazon-ssm-agent --no-pager

# Enable password authentication for SSH
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config 
sudo systemctl reload sshd

# Create interviewee user
USERNAME="${username}"
USERPASS="${password}"
sudo adduser $USERNAME
sudo read -s USERPASS
sudo echo "$USERNAME:$USERPASS" | sudo chpasswd
sudo unset USERPASS
sudo usermod -aG wheel $USERNAME

# Configure log rotation for user data log
echo "Setting up log rotation..."
cat > /etc/logrotate.d/user-data << EOF
/var/log/user-data.log {
    daily 
    missingok
    rotate 7
    compress
    notifempty
    create 0644 root root
}
EOF

echo "User data script completed successfully at $(date)"
