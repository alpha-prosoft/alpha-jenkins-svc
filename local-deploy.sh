#!/bin/bash

export TARGET_ACCOUNT_ID="$(aws sts get-caller-identity | jq -r '.Account')"
export DOCKER_BUILDKIT=0

export TARGET=ubuntu@${1}
if [[ "${1:-}" != "" ]]; then
  export DOCKER_HOST=ssh://${TARGET}
fi
export BUILD_ID="29"

./build.sh && ./run.sh
