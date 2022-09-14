#!/bin/sh

set -eux pipefail

if ! [ $(which niet) ]; then
    echo 'niet is not installed; install it with pip'
    exit 1
fi

CLEAN_YAML=$(cat .drone.yml | sed 's/---//g' | sed 's/\.\.\.//g')

BUILD_VERSION=$(echo "${CLEAN_YAML}" | niet .steps[0].settings.tags[1] -)

BUILD_ARGS_RAW=$(echo "${CLEAN_YAML}" | niet .steps[0].settings.build_args -)
BUILD_ARGS=$(for b in ${BUILD_ARGS_RAW}; do echo "--build-arg ${b}"; done)

exec docker build ${BUILD_ARGS} -t "superseriousbusiness/gotosocial-drone-build:${BUILD_VERSION}" .
