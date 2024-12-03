#!/bin/bash

set -eou pipefail

export TARGET_ACCOUNT_ID="$(aws sts get-caller-identity | jq -r '.Account')"

export DOCKER_BUILDKIT=1

SESSION_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
export AWS_DEFAULT_REGION=$(curl -s -H "X-aws-ec2-metadata-token: $SESSION_TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

export LATEST_IMAGE="$(aws ec2 describe-images \
                          --owners self --no-paginate  \
			  | jq -r '.Images[].Name' \
			  | grep build-alpha-jenkins  \
			  | sort | tail -1)"

echo "Last image found: $LATEST_IMAGE"

if [[ "$LATEST_IMAGE" == "" ]]; then
  export BUILD_ID="0"
else
  export BUILD_ID="${LATEST_IMAGE##*.b}"
fi
export BUILD_ID=$((BUILD_ID+1))
echo "New build id: $BUILD_ID"



docker build --progress=plain \
             --no-cache \
             --pull \
	     --build-arg BUILD_ID="${BUILD_ID}" \
	     --build-arg BuildId="${BUILD_ID}" \
	     --build-arg AWS_REGION="${AWS_DEFAULT_REGION}" \
      	     --build-arg AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
	     --build-arg DOCKER_REGISTRY_URL="${DOCKER_REGISTRY_URL}" \
	     -t alpha-jenkins-svc:b${BUILD_ID} \
	     -f Dockerfile .

