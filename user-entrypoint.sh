#!/usr/bin/env sh
set -e

# This image cannot be run with the --user flag
if [ $(id -u) -ne 0 ]; then
    echo "ERROR: This image should not be run with the --user Docker flag. Exiting..."
    exit 1
fi

# Set the timezone if specified
if [ ! -z ${TZ+x} ]; then
    if [ -f "/usr/share/zoneinfo/${TZ}" ]; then
        rm -f /etc/localtime
        cp /usr/share/zoneinfo/${TZ} /etc/localtime
        echo "${TZ}" > /etc/timezone
        echo "Timezone set to ${TZ}"
    else
        echo "Environment variable TZ (${TZ}) is invalid, ignoring..."
    fi
fi

# Build our exec command
EXEC_COMMAND="$@"

# Get the PUID and PGID, default to 1000 if not defined
PUID=${PUID:-1000}
PGID=${PGID:-$PUID}

# Set permissions and custom exec commands, if applicable
if [ ${PUID} -ne 0 ]; then
    # Non-root needs su-exec to run the command
    EXEC_COMMAND="su-exec docker ${EXEC_COMMAND}"

    usermod -o -u ${PUID} docker >/dev/null 2>&1
    groupmod -o -g ${PGID} docker >/dev/null 2>&1

    for folder in config data; do
        if [ ! -f /${folder}/.permissions-set ]; then
            # First run
            touch /${folder}/.permissions-set
            chown -R docker:docker /${folder}
        elif [ $(stat -c "%u" /${folder}/.permissions-set) -ne ${PUID} ] || [ $(stat -c "%g" /${folder}/.permissions-set) -ne ${PGID} ]; then
            # Subsequent run, PUID/PGID changed from previous run
            echo "Resetting all permissions in directory \"/${folder}\" to UID/GID: ${PUID}/${PGID}"
            chown -R docker:docker /${folder}
        else
            # Subsequent run, PUID/PGID have not changed. Still chown the directory in case this is volume mounted (folder would otherwise be owned by root)
            chown docker:docker /${folder}
        fi
    done
else
    for folder in config data; do
        if [ -f /${folder}/.permissions-set ]; then
            chown root:root /${folder}/.permissions-set
        fi
    done
fi

# Set niceness if defined
if [ ! -z ${NICENESS+x} ]; then
    NICE_CMD="$(which nice) -n ${NICENESS}"
    # NOTE: On debian systems, nice always has an exit code of `0`, even when
    # permission is denied. Look for the error message instead.
    if [ "$(${NICE_CMD} true 2>&1)" != "" ]; then
        echo "ERROR: Permission denied to set application's niceness to" \
             "'${NICENESS}'. Make sure the container is started with the" \
             "'--cap-add=SYS_NICE' option. Exiting..."
        exit 1
    fi
    echo "Niceness set to ${NICENESS}"
    EXEC_COMMAND="${NICE_CMD} ${EXEC_COMMAND}"
fi

# Start the process!
if [ ${PUID} -eq 0 ]; then
    echo "Starting as root user"
else
    echo "Starting with UID/GID: ${PUID}/${PGID}"
fi
exec ${EXEC_COMMAND}
