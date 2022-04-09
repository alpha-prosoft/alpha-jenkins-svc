#!/bin/bash

set -e 


echo "Building alpha-jenkins-svc ${BUILD_ID}"

curl https://raw.githubusercontent.com/raiffeisenbankinternational/cbd-jenkins-pipeline/master/ext/deploy.sh > deploy.sh
chmod +x deploy.sh

docker build --progress=plain \
             --no-cache \
	     --build-arg BUILD_ID="${BUILD_ID}" \
	     --build-arg BuildId="${BUILD_ID}" \
	     -t alpha-jenkins-svc:b${BUILD_ID} \
	     -f Dockerfile .


