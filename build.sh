#!/bin/bash

set -e 

export TARGET_ACCOUNT_ID="$(aws sts get-caller-identity | jq -r '.Account')"
export DOCKER_BUILDKIT=0
export DOCKER_BUILDKIT=1

export TARGET=ubuntu@${1}
if [[ "${1:-}" != "" ]]; then
  export DOCKER_HOST=ssh://${TARGET}
fi
export BUILD_ID="74"

export AWS_DEFAULT_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

docker build --progress=plain \
             --no-cache \
	     --build-arg BUILD_ID="${BUILD_ID}" \
	     --build-arg BuildId="${BUILD_ID}" \
	     --build-arg AWS_REGION="${AWS_DEFAULT_REGION}" \
	     -t alpha-jenkins-svc:b${BUILD_ID} \
	     -f Dockerfile .


