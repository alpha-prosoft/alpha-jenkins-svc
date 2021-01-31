#!/bin/bash

export BUILD_ID="17"

export TARGET_ACCOUNT_ID="$(aws sts get-caller-identity | jq -r '.Account')"

./build.sh && ./run.sh


