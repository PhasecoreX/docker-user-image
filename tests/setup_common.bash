get_init_script_exit_code() {
    script=$1
    lines=$2
    regex="^\[cont-init\.d\] ${script}: exited ([0-9]+)\.$"

    for item in "${lines[@]}"; do
        if [[ "${item}" =~ ${regex} ]]; then
            echo "${BASH_REMATCH[1]}"
            return 0
        fi
    done

    echo "ERROR: No exit code found for init script '${script}'." >&2
    return 1
}

docker_run() {
    run docker run "$@"
}

# Make sure the docker image exists.
[ -n "${DOCKER_IMAGE:-}" ]
docker inspect "${DOCKER_IMAGE}" >/dev/null

# Make sure helper_permissions.sh exists
[ -n "${HELPER_PERMISSIONS:-}" ]
[ -f "${HELPER_PERMISSIONS:-}" ]
