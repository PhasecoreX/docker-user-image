#!/usr/bin/env bats

setup() {
    load setup_common
}

@test "Checking that a positive niceness value can be set successfully..." {
    docker_run --rm -e "NICENESS=19" "$DOCKER_IMAGE"
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Niceness set to 19" ]
}

@test "Checking that a negative niceness value fails without the --cap-add=SYS_NICE option..." {
    docker_run --rm -e "NICENESS=-1" "$DOCKER_IMAGE"
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 1 ]
}

@test "Checking that a negative niceness value succeed with the --cap-add=SYS_NICE option..." {
    docker_run --rm -e "NICENESS=-1" --cap-add=SYS_NICE "$DOCKER_IMAGE"
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Niceness set to -1" ]
}

