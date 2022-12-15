#!/usr/bin/env bats

setup() {
    load setup_common
}

@test "Testing TZ=America/Detroit with /etc/localtime" {
    docker_run --rm -e TZ=America/Detroit -v /etc/localtime:/etc/localtime "$DOCKER_IMAGE" sh -c date
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "/etc/localtime file mounted, ignoring environment variable TZ..." ]
}

@test "Testing TZ=America/Detroit with /etc/timezone" {
    docker_run --rm -e TZ=America/Detroit -v /etc/timezone:/etc/timezone "$DOCKER_IMAGE" sh -c date
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Skipping /etc/timezone file update, as it is mounted from host" ]
    [ "${lines[1]}" = "Timezone set to America/Detroit" ]
}

@test "Testing TZ=America/Detroit" {
    docker_run --rm -e TZ=America/Detroit "$DOCKER_IMAGE" sh -c date
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Timezone set to America/Detroit" ]
}

@test "Testing TZ=Etc/UTC" {
    docker_run --rm -e TZ=Etc/UTC "$DOCKER_IMAGE" sh -c date
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Timezone set to Etc/UTC" ]
}
