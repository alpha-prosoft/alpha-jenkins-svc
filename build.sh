#!/bin/bash

set -e 


echo "Building alpha-jenkins-svc ${BUILD_ID}"

docker build --progress=plain \
             --no-cache \
	     --build-arg BUILD_ID="${BUILD_ID}" \
	     --build-arg BuildId="${BUILD_ID}" \
	     -t alpha-jenkins-svc:b${BUILD_ID} \
	     -f Dockerfile .


