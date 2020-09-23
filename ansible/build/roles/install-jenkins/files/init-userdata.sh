#!/bin/bash 

jira_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/jira-http" \
	                  --query "SecretString" --output text)"

export JiraHttpUser="$(echo ${jira_http} | jq -r '.username')"
export JiraHttpPassword="$(echo ${jira_http} | jq -r '.password')"

echo "JiraHttpUser=${JiraHttpUser}" >> /etc/environment
echo "JiraHttpPassword=${JiraHttpPassword}" >> /etc/environment


cat << EOF /opt/startup.sh
set -e

mkdir /home/jenkins/.ssh

aws ssm get-parameter \
        --name "/pipeline/public/jenkins/.ssh/id_rsa.pub" \
        --with-decryption \
        --query 'Parameter.Value' \
        --output text | base64 -d > /home/jenkins/.ssh/authorized_keys
chown jenkins:jenkins /home/jenkins/.ssh/authorized_keys
/opt/login-job.sh

EOF
chmod +x /opt/startup.sh

cat << EOF /etc/systemd/system/agent-init.service
[Unit]
Description=Execute init script
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/startup.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl enable agent-init.service



echo "Preparing configuration"
envsubst < /etc/jenkins/jenkins-configuration-template.yml | tee /etc/jenkins/jenkins-configuration.yml
envsubst < /etc/jenkins/gerrit-trigger-template.xml | tee /var/lib/jenkins/gerrit-trigger.xml

chown jenkins:jenkins /var/lib/jenkins -R

echo "Starting jenkins"

systemctl start jenkins

