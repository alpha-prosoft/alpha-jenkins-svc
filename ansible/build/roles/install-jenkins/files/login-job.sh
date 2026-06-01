#!/bin/bash

set -euxo pipefail

source /etc/environment

username="jenkins"
password=$(aws ssm get-parameter \
  --name "/${EnvironmentNameLower}/${username}/password" \
  --with-decryption \
  --query "Parameter.Value" --output text)

. /etc/environment
/opt/login.sh \
  "${username}" \
  "${password}" \
  "/home/${Username}/.gitcookie" \
  "/home/${Username}/.gitconfig"
