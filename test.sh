#!/usr/bin/env bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"

for image in alpine debian ubuntu python; do
    echo ""

    echo "Building $image"
    sudo docker build . --pull --tag "phasecorex/user-$image:test-bats" --build-arg "BASE_IMG=$image:latest"

    echo "Testing $image"
    sudo DOCKER_IMAGE="phasecorex/user-$image:test-bats" HELPER_PERMISSIONS="$(readlink -f ./tests/helper_permissions.sh)" bats tests
done
