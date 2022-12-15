#!/usr/bin/env sh
set -eu

# This image cannot be run with the --user flag
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This image should not be run with the --user Docker flag. Exiting..."
    exit 1
fi

# If this is during the image build, we run this and exit
if [ "$1" = "--init" ]; then
    if command -v apk >/dev/null 2>&1; then
        # alpine
        apk add --no-cache shadow su-exec tzdata
    elif command -v apt-get >/dev/null 2>&1; then
        # debian
        savedAptMark="$(apt-mark showmanual)"
        apt-get update
        apt-get install -y --no-install-recommends ca-certificates curl unzip make gcc libc6-dev

        SU_EXEC_HASH="212b75144bbc06722fbd7661f651390dc47a43d1"
        curl -L https://github.com/ncopa/su-exec/archive/${SU_EXEC_HASH}.zip -o su-exec.zip
        unzip su-exec.zip
        cd su-exec-*
        make su-exec
        cp ./su-exec /bin/su-exec
        cd ..
        rm su-exec* -rf
        su-exec nobody true

        apt-mark auto '.*' > /dev/null
        [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

        # add timezone functionality if missing
        if [ ! -d /usr/share/zoneinfo ]; then
            apt-get install -y --no-install-recommends tzdata
        fi

        # clean up
        rm -rf /var/lib/apt/lists/*
    else
        # unsupported
        echo "This base image is unsupported!"
        exit 1
    fi

    # add user and group
    groupadd --gid 1000 docker
    useradd --no-log-init --uid 1000 --gid 1000 --home-dir /config --shell /bin/false docker
    mkdir -p \
        /config \
        /data

    exit 0
fi

# Set the timezone if specified
if [ -n "${TZ:-}" ]; then
    if [ -f /etc/localtime ] && [ "$(stat -c "%d" "$(readlink -f /etc/localtime)")" -ne "$(stat -c "%d" /)" ]; then
        echo "/etc/localtime file mounted, ignoring environment variable TZ..."
    elif [ -f "/usr/share/zoneinfo/${TZ}" ]; then
        ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
        if [ -f /etc/timezone ] && [ "$(stat -c "%d" "$(readlink -f /etc/timezone)")" -ne "$(stat -c "%d" /)" ]; then
            echo "Skipping /etc/timezone file update, as it is mounted from host"
        else
            echo "${TZ}" >/etc/timezone
        fi
        echo "Timezone set to ${TZ}"
    else
        echo "Environment variable TZ (${TZ}) is invalid, ignoring..."
    fi
fi

# Get the PUID and PGID, default to 1000 if not defined
PUID=${PUID:-1000}
PGID=${PGID:-${PUID}}

# Set permissions and custom exec commands, if applicable
if [ "${PUID}" -ne "0" ]; then
    # Non-root needs su-exec to run the command
    set "su-exec" "docker" "$@"

    usermod -o -u "${PUID}" docker >/dev/null 2>&1
    groupmod -o -g "${PGID}" docker >/dev/null 2>&1

    for folder in config data; do
        if [ ! -d "/${folder}" ]; then
            # Skip non-existant folders
            true
        elif [ ! -f "/${folder}/.permissions-set" ]; then
            # First run
            touch "/${folder}/.permissions-set"
            chown -R docker:docker "/${folder}"
        elif [ "$(stat -c "%u" "/${folder}/.permissions-set")" -ne "${PUID}" ] || [ "$(stat -c "%g" "/${folder}/.permissions-set")" -ne "${PGID}" ]; then
            # Subsequent run, PUID/PGID changed from previous run
            echo "Resetting all permissions in directory \"/${folder}\" to UID/GID: ${PUID}/${PGID}"
            chown -R docker:docker "/${folder}"
        elif [ "$(stat -c "%u" "/${folder}")" -ne "${PUID}" ] || [ "$(stat -c "%g" "/${folder}")" -ne "${PGID}" ]; then
            # Subsequent run, PUID/PGID have not changed for contained files, but directory itself isn't owned by PUID/PGID (directory is probably volume mounted and owned by root)
            chown docker:docker "/${folder}"
        fi
    done
else
    for folder in config data; do
        if [ -f "/${folder}/.permissions-set" ]; then
            if [ "$(stat -c "%u" "/${folder}/.permissions-set")" -ne "0" ] || [ "$(stat -c "%g" "/${folder}/.permissions-set")" -ne "0" ]; then
                chown root:root "/${folder}/.permissions-set"
            fi
        fi
    done
fi

# Set niceness if defined
if [ -n "${NICENESS:-}" ]; then
    # NOTE: On debian systems, nice always has an exit code of `0`, even when
    # permission is denied. Look for the error message instead.
    if [ "$($(command -v nice) -n "${NICENESS}" true 2>&1)" != "" ]; then
        echo "ERROR: Permission denied to set application's niceness to" \
            "'${NICENESS}'. Make sure the container is started with the" \
            "'--cap-add=SYS_NICE' option. Exiting..."
        exit 1
    fi
    echo "Niceness set to ${NICENESS}"
    set "$(command -v nice)" "-n" "${NICENESS}" "$@"
fi

# Start the process!
if [ "${PUID}" -eq 0 ]; then
    echo "Starting as root user"
else
    echo "Starting with UID/GID: ${PUID}/${PGID}"
fi
exec "$@"
