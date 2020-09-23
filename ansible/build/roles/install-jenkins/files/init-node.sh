#!/bin/bash
set -e

source /etc/environment

mkdir -p /home/jenkins/.ssh

aws ssm get-parameter \
        --name "/pipeline/public/jenkins/.ssh/id_rsa.pub" \
        --with-decryption \
        --query 'Parameter.Value' \
        --output text | base64 -d > /home/jenkins/.ssh/authorized_keys
chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
/opt/login-job.sh


