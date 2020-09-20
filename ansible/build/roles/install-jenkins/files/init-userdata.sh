#!/bin/bash 

echo "Preparing configuration"
envsubst < /etc/jenkins/jenkins-configuration-template.yml | tee /etc/jenkins/jenkins-configuration.yml
envsubst < /etc/jenkins/gerrit-trigger-template.xml | tee /var/lib/jenkins/gerrit-trigger.xml

chown jenkins:jenkins /var/lib/jenkins -R

echo "Starting jenkins"

systemctl start jenkins

