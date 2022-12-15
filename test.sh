#!/usr/bin/env bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"

echo "Building Alpine"
sudo docker build . --pull --tag phasecorex/user-alpine:test-bats --build-arg BASE_IMG=alpine:latest

echo "Testing Alpine"
sudo DOCKER_IMAGE=phasecorex/user-alpine:test-bats HELPER_PERMISSIONS="$(readlink -f ./tests/helper_permissions.sh)" bats tests

echo ""

echo "Building Debain"
sudo docker build . --pull --tag phasecorex/user-debian:test-bats --build-arg BASE_IMG=debian:latest

echo "Testing Debian"
sudo DOCKER_IMAGE=phasecorex/user-debian:test-bats HELPER_PERMISSIONS="$(readlink -f ./tests/helper_permissions.sh)" bats tests
