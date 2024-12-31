#!/bin/bash 

set -e

systemctl stop jenkins

aws secretsmanager  get-secret-value \
	  --secret-id "/${EnvironmentNameLower}/jenkins/config" \
	  --query "SecretString" --output text > /etc/jenkins-config.json

cat <<EOF > /opt/render.py
import jinja2, json, sys

data = {}
with open("/etc/jenkins-config.json") as f:
    data = json.load(f)

with open("/etc/environment.json") as f:
    data["environment"] = json.load(f)

templateLoader = jinja2.FileSystemLoader(searchpath="./")
templateEnv = jinja2.Environment(loader=templateLoader)
template = templateEnv.get_template(sys.argv[1])

with open(sys.argv[2], "w") as f:
    f.write(template.render(data))
EOF


echo "Preparing configuration"
python3 /opt/render.py \
    /etc/jenkins/jenkins-configuration-template.yml \
    /etc/jenkins/jenkins-configuration.yml

python3 /opt/render.py \
    /etc/jenkins/gerrit-trigger-template.xml \
    /var/lib/jenkins/gerrit-trigger.xml
    
chown jenkins:jenkins /var/lib/jenkins/*.xml -R

echo "Starting jenkins"
rm -rf /var/lib/jenkins/plugins/*
cp /opt/jenkins/plugins/* /var/lib/jenkins/plugins/
chown -R jenkins:jenkins /var/lib/jenkins/plugins/

systemctl daemon-reload
systemctl start jenkins

