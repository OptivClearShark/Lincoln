#!/bin/bash

# Log all output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script execution at $(date)"

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