#!/bin/bash 

set -e

jira_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/jira-http" \
	                  --query "SecretString" --output text)"

export JiraHttpUser="$(echo ${jira_http} | jq -r '.username')"
export JiraHttpPassword="$(echo ${jira_http} | jq -r '.password')"
export JiraHttpUrl="$(echo ${jira_http} | jq -r '.url')"

echo "JiraHttpUser=${JiraHttpUser}" >> /etc/environment
echo "JiraHttpPassword=${JiraHttpPassword}" >> /etc/environment
echo "JiraHttpUrl=${JiraHttpUrl}" >> /etc/environment


github_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/github-http" \
	                  --query "SecretString" --output text)"

export GithubHttpUser="$(echo ${github_http} | jq -r '.username')"
export GithubHttpPassword="$(echo ${github_http} | jq -r '.password')"
export GithubHttpUrl="$(echo ${github_http} | jq -r '.url')"

echo "GithubHttpUser=${GithubHttpUser}" >> /etc/environment
echo "GithubHttpPassword=${GithubHttpPassword}" >> /etc/environment
echo "GithubHttpUrl=${GithubHttpUrl}" >> /etc/environment


docker_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/docker-http" \
	                  --query "SecretString" --output text)"

export DockerPushHttpUrl="$(echo ${docker_http} | jq -r '."push-url"')"
export DockerHttpUser="$(echo ${docker_http} | jq -r '.username')"
export DockerHttpPassword="$(echo ${docker_http} | jq -r '.password')"
export DockerHttpUrl="$(echo ${docker_http} | jq -r '.url')"
export DockerHttpOrg="$(echo ${docker_http} | jq -r '.org')"

echo "DockerPushHttpUrl=${DockerPushHttpUrl}" >> /etc/environment
echo "DockerHttpUser=${DockerHttpUser}" >> /etc/environment
echo "DockerHttpPassword=${DockerHttpPassword}" >> /etc/environment
echo "DockerHttpUrl=${DockerHttpUrl}" >> /etc/environment
echo "DockerHttpOrg=${DockerHttpOrg}" >> /etc/environment


artifact_deploy_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/artifact-deploy-http" \
	                  --query "SecretString" --output text)"

export ArtifactDeployHttpUser="$(echo ${artifact_deploy_http} | jq -r '.username')"
export ArtifactDeployHttpPassword="$(echo ${artifact_deploy_http} | jq -r '.password')"
export ArtifactDeployHttpUrl="$(echo ${artifact_deploy_http} | jq -r '.url')"
export ArtifactDeployOrg="$(echo ${artifact_deploy_http} | jq -r '.org')"

echo "ArtifactDeployHttpUser=${ArtifactDeployHttpUser}" >> /etc/environment
echo "ArtifactDeployHttpPassword=${ArtifactDeployHttpPassword}" >> /etc/environment
echo "ArtifactDeployHttpUrl=${ArtifactDeployHttpUrl}" >> /etc/environment
echo "ArtifactDeployOrg=${ArtifactDeployOrg}" >> /etc/environment


artifact_deploy_public_http="$(aws  secretsmanager  get-secret-value \
     	                       --secret-id "/${EnvironmentNameLower}/jenkins/artifact-deploy-public-http" \
	                       --query "SecretString" --output text)"

export ArtifactDeployPublicHttpUser="$(echo ${artifact_deploy_http} | jq -r '.username')"
export ArtifactDeployPublicHttpPassword="$(echo ${artifact_deploy_http} | jq -r '.password')"
export ArtifactDeployPublicHttpUrl="$(echo ${artifact_deploy_http} | jq -r '.url')"
export ArtifactDeployPublicOrg="$(echo ${artifact_deploy_http} | jq -r '.org')"

echo "ArtifactDeployPublicHttpUser=${ArtifactDeployPublicHttpUser}" >> /etc/environment
echo "ArtifactDeployPublicHttpPassword=${ArtifactDeployPublicHttpPassword}" >> /etc/environment
echo "ArtifactDeployPublicHttpUrl=${ArtifactDeployPublicHttpUrl}" >> /etc/environment
echo "ArtifactDeployPublicOrg=${ArtifactDeployPublicOrg}" >> /etc/environment


artifact_deploy_dev_http="$(aws  secretsmanager  get-secret-value \
	                  --secret-id "/${EnvironmentNameLower}/jenkins/artifact-deploy-dev-http" \
	                  --query "SecretString" --output text)"

export ArtifactDeployDevHttpUser="$(echo ${artifact_deploy_dev_http} | jq -r '.username')"
export ArtifactDeployDevHttpPassword="$(echo ${artifact_deploy_dev_http} | jq -r '.password')"
export ArtifactDeployDevHttpUrl="$(echo ${artifact_deploy_dev_http} | jq -r '.url')"
export ArtifactDeployDevOrg="$(echo ${artifact_deploy_dev_http} | jq -r '.org')"

echo "ArtifactDeployDevHttpUser=${ArtifactDeployDevHttpUser}" >> /etc/environment
echo "ArtifactDeployDevHttpPassword=${ArtifactDeployDevHttpPassword}" >> /etc/environment
echo "ArtifactDeployDevHttpUrl=${ArtifactDeployDevHttpUrl}" >> /etc/environment
echo "ArtifactDeployDevOrg=${ArtifactDeployDevOrg}" >> /etc/environment

echo "Preparing configuration"
envsubst < /etc/jenkins/jenkins-configuration-template.yml | tee /etc/jenkins/jenkins-configuration.yml
sed -e 's/§/\^$/g' -i /etc/jenkins/jenkins-configuration.yml 

envsubst < /etc/jenkins/gerrit-trigger-template.xml | tee /var/lib/jenkins/gerrit-trigger.xml

chown jenkins:jenkins /var/lib/jenkins -R

crontab -l | { cat; echo "* * * * * $(which aws) s3 cp s3://${AccountId}-${EnvironmentNameLower}-configuration/accounts.json /var/lib/jenkins/accounts.json"; } | crontab -

echo "Starting jenkins"

rm -rf /var/lib/jenkins/plugins/*
cp /opt/jenkins/plugins/* /var/lib/jenkins/plugins/
chown -R jenkins:jenkins /var/lib/jenkins/plugins/

systemctl start jenkins

