#!/usr/bin/env bash
set -euo pipefail

# Variables passed via Packer environment_vars
SPLUNK_VERSION="${SPLUNK_VERSION:-${1:-}}"
SPLUNK_WGET_URL="${SPLUNK_WGET_URL:-${2:-}}"
TIMEZONE="${TIMEZONE:-UTC}"
SECRET_ID="${SECRET_ID:-}"
SECRET_DEST="${SECRET_DEST:-}"

log() {
  echo "[splunk_setup] $(date -u +"%Y-%m-%dT%H:%M:%SZ") - $*"
}

log "Checking region"
AWS_REGION="$(curl -s --connect-timeout 2 http://169.254.169.254/latest/dynamic/instance-identity/document \
  | grep -oE '"region"\s*:\s*"[^"]+"' \
  | cut -d'"' -f4)"

log "Setting timezone to ${TIMEZONE}"
sudo timedatectl set-timezone "${TIMEZONE}" || true

log "Updating system and installing prerequisites"
sudo dnf update -y
sudo dnf install -y wget unzip amazon-ssm-agent vim awscli

log "Enabling and starting SSM Agent"
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

log "Creating splunk user and directories"
if ! id splunk >/dev/null 2>&1; then
  sudo useradd -r -m -U -d /opt/splunk -s /bin/bash splunk
fi
sudo mkdir -p /opt/splunk
sudo chown -R splunk:splunk /opt/splunk

if [[ -n "${SPLUNK_WGET_URL:-}" ]]; then
  log "Downloading Splunk Enterprise ${SPLUNK_VERSION:-unknown}"
  pushd /tmp >/dev/null
  wget -O splunk.tgz -q "${SPLUNK_WGET_URL}"
  log "Extracting Splunk Enterprise"
  sudo tar -xzf splunk.tgz -C /opt/
  sudo chown -R splunk:splunk /opt/splunk
  rm -f /tmp/splunk.tgz || true
  popd >/dev/null
else
  log "SPLUNK_WGET_URL not provided; skipping Splunk download/install"
fi

log "Configuring Splunk Enterprise"
sudo /opt/splunk/bin/splunk enable boot-start -user splunk --accept-license --answer-yes -systemd-managed 1 --seed-passwd 'changeme'
sudo chown -R splunk:splunk /opt/splunk
sudo systemctl start Splunkd || true
sudo systemctl stop Splunkd || true
sudo -u splunk /opt/splunk/bin/splunk clone-prep-clear-config
sudo -u splunk mkdir -p /opt/splunk/etc/apps/ocs_all_web_ssl/default
sudo -u splunk mkdir -p /opt/splunk/etc/auth/mycerts
sudo aws --region $AWS_REGION secretsmanager get-secret-value --secret-id csworks/privkey --query SecretString --output text | sudo tee /opt/splunk/etc/auth/mycerts/privkey.pem
sudo chown splunk:splunk /opt/splunk/etc/auth/mycerts/privkey.pem
sudo chmod 600 /opt/splunk/etc/auth/mycerts/privkey.pem
sudo aws --region $AWS_REGION s3 cp s3://lincoln-objects/clearsharkworks-pub.pem /opt/splunk/etc/auth/mycerts/cert.pem
sudo chown splunk:splunk /opt/splunk/etc/auth/mycerts/cert.pem
sudo -u splunk chmod 644 /opt/splunk/etc/auth/mycerts/cert.pem
sudo -u splunk echo -e "[settings]\nenableSplunkWebSSL = true\nprivKeyPath = /opt/splunk/etc/auth/mycerts/privkey.pem\nserverCert = /opt/splunk/etc/auth/mycerts/cert.pem" | sudo -u splunk tee /opt/splunk/etc/apps/ocs_all_web_ssl/default/web.conf
sudo -u splunk rm -f /opt/splunk/etc/system/local/*
sudo -u splunk echo -e "[user_info]\nUSERNAME = admin\nPASSWORD = changeme" | sudo -u splunk tee /opt/splunk/etc/system/local/user-seed.conf


log "Final system cleanup"
sudo dnf clean all
sudo rm -rf /var/cache/dnf/* /tmp/* /var/tmp/*
history -c || true

log "Setup complete"
