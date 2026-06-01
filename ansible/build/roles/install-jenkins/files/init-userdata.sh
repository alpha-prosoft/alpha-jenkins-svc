#!/bin/bash

set -euo pipefail

log() { echo "[init-userdata] $(date -u +%FT%TZ) $*"; }

config_param="/${EnvironmentNameLower}/jenkins/config"
config_file="/etc/jenkins-config.json"

log "Stopping jenkins"
systemctl stop jenkins || true

log "Reading configuration from SSM parameter ${config_param}"
attempt=1
until aws ssm get-parameter \
  --name "${config_param}" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text >"${config_file}.tmp"; do
  if [[ "${attempt}" -ge 5 ]]; then
    log "ERROR: could not read ${config_param} after ${attempt} attempts"
    exit 1
  fi
  log "Read failed (attempt ${attempt}), retrying in 5s"
  attempt=$((attempt + 1))
  sleep 5
done

log "Validating configuration"
python3 -c "import json; json.load(open('${config_file}.tmp'))"
mv "${config_file}.tmp" "${config_file}"
chmod 600 "${config_file}"

log "Rendering jenkins configuration"
python3 /opt/render.py \
  /etc/jenkins/jenkins-configuration-template.yml \
  /etc/jenkins/jenkins-configuration.yml

log "Rendering gerrit trigger configuration"
python3 /opt/render.py \
  /etc/jenkins/gerrit-trigger-template.xml \
  /var/lib/jenkins/gerrit-trigger.xml

chown -R jenkins:jenkins /var/lib/jenkins/*.xml

log "Refreshing plugins"
rm -rf /var/lib/jenkins/plugins/*
cp /opt/jenkins/plugins/* /var/lib/jenkins/plugins/
chown -R jenkins:jenkins /var/lib/jenkins/plugins/

log "Starting jenkins"
systemctl daemon-reload
systemctl start jenkins

log "Enabling timers"
systemctl enable --now alpha-login.timer
systemctl enable --now init-node.timer

log "Done"
