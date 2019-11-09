#!/usr/bin/env sh
set -e

if [ $(id -u) -ne 0 ]; then
    echo "ERROR: This image should not be run with the --user Docker flag. Exiting..."
    exit 1
fi

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

PUID=${PUID:-1000}
PGID=${PGID:-$PUID}

if [ ${PUID} -eq 0 ]; then
    for folder in config data; do
        if [ -f /${folder}/.permissions-set ]; then
            chown root:root /${folder}/.permissions-set
        fi
    done
    echo "Starting as root user"
    exec "$@"
fi

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

echo "Starting with UID/GID: ${PUID}/${PGID}"
exec su-exec docker "$@"
