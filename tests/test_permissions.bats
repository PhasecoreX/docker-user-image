#!/usr/bin/env bats

setup() {
    load setup_common
}

@test "Testing no /data mount PUID 1000..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -e PUID=1000 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting with UID/GID: 1000/1000" ]
}


@test "Testing no /data mount PUID 1001..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -e PUID=1001 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting with UID/GID: 1001/1001" ]
}


@test "Testing no /data mount PUID 0..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -e PUID=0 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting as root user" ]
}

@test "Testing /data volume mount PUID 1000..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v testvolumemount:/data -e PUID=1000 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting with UID/GID: 1000/1000" ]
}

@test "Testing /data volume mount PUID 1000 -> 1001..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v testvolumemount:/data -e PUID=1001 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Resetting all permissions in directory \"/data\" to UID/GID: 1001/1001" ]
    [ "${lines[1]}" = "Starting with UID/GID: 1001/1001" ]
}

@test "Testing /data volume mount PUID 0..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v testvolumemount:/data -e PUID=0 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting as root user" ]
}

@test "Testing /data volume mount PUID 0 -> 1000..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v testvolumemount:/data -e PUID=1000 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Resetting all permissions in directory \"/data\" to UID/GID: 1000/1000" ]
    [ "${lines[1]}" = "Starting with UID/GID: 1000/1000" ]
}

@test "Testing /data volume mount PUID 1000 -> 1000..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v testvolumemount:/data -e PUID=1000 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting with UID/GID: 1000/1000" ]
}

@test "Testing /data bind mount PUID 1000..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v /tmp/testbindmount:/data -e PUID=1000 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting with UID/GID: 1000/1000" ]
}

@test "Testing /data bind mount PUID 1000 -> 1001..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v /tmp/testbindmount:/data -e PUID=1001 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Resetting all permissions in directory \"/data\" to UID/GID: 1001/1001" ]
    [ "${lines[1]}" = "Starting with UID/GID: 1001/1001" ]
}

@test "Testing /data bind mount PUID 0..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v /tmp/testbindmount:/data -e PUID=0 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting as root user" ]
}

@test "Testing /data bind mount PUID 0 -> 1000..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v /tmp/testbindmount:/data -e PUID=1000 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Resetting all permissions in directory \"/data\" to UID/GID: 1000/1000" ]
    [ "${lines[1]}" = "Starting with UID/GID: 1000/1000" ]
}

@test "Testing /data bind mount PUID 1000 -> 1000..." {
    docker_run --rm -v "$HELPER_PERMISSIONS":/helper_permissions.sh -v /tmp/testbindmount:/data -e PUID=1000 "$DOCKER_IMAGE" /helper_permissions.sh
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Starting with UID/GID: 1000/1000" ]
}

@test "Cleaning up permissions tests..." {
    run rm -rf /tmp/testbindmount
    run docker volume rm testvolumemount
    echo "====================================================================="
    echo " OUTPUT"
    echo "====================================================================="
    echo "$output"
    echo "====================================================================="
    echo " END OUTPUT"
    echo "====================================================================="
    echo "STATUS: $status"
    [ "$status" -eq 0 ]
}

