#!/bin/bash

set -e 

echo "Going to deploy me some stuff"

curl https://raw.githubusercontent.com/raiffeisenbankinternational/cbd-jenkins-pipeline/master/ext/deploy.sh > deploy.sh
chmod +x deploy.sh



export TARGET_ACCOUNT_ID="$(aws sts get-caller-identity | jq -r '.Account')"

docker run -v /var/run/docker.sock:/var/run/docker.sock \
	  -e TargetAccountId="${TARGET_ACCOUNT_ID}" \
	  -e EnvironmentNameUpper="PIPELINE" \
	  -e ServiceName="alpha-jenkins-svc" \
	  -e BUILD_ID="${BUILD_ID}" \
	  -v $PWD/deploy.sh:/dist/deploy.sh \
	  alpha-jenkins-svc:b${BUILD_ID} /dist/deploy.sh
