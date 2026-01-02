#!/bin/bash

set -euxo pipefail

source /etc/environment

username="jenkins"
password=$(aws secretsmanager get-secret-value \
  --query "SecretString" --output text \
  --secret-id "/${EnvironmentNameLower}/${username}/password")

. /etc/environment
/opt/login.sh \
  "${username}" \
  "${password}" \
  "/home/${Username}/.gitcookie" \
  "/home/${Username}/.gitconfig"
