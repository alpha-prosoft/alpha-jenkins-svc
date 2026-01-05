#!/bin/bash

set -euo pipefail

export PROJECT_NAME=${1}
export ENV_NAME_UPPER=${2:-PIPELINE}

target_dir=${PWD}/target
mkdir -p $target_dir

curl -H 'Cache-Control: no-cache' \
  https://raw.githubusercontent.com/alpha-prosoft/cbd-jenkins-pipeline/master/ext/build.sh \
  >$target_dir/build.sh

curl -H 'Cache-Control: no-cache' \
  https://raw.githubusercontent.com/alpha-prosoft/cbd-jenkins-pipeline/master/ext/run.sh \
  >$target_dir/run.sh

chmod +x ${target_dir}/build.sh
chmod +x ${target_dir}/run.sh

source ${target_dir}/build.sh ${PROJECT_NAME} "jenkins" "${ENV_NAME_UPPER}"
