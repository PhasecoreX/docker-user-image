#!/usr/bin/env sh
set -e

if [ $(id -u) -ne 0 ]; then
    echo "ERROR: This image should not be run with the --user Docker flag. Exiting..."
    exit 1
fi

PUID=${PUID:-1000}
PGID=${PGID:-$PUID}

if [ ! -z ${TZ+x} ]; then
    if [ -f "/usr/share/zoneinfo/$TZ" ]; then
        rm -f /etc/localtime
        cp /usr/share/zoneinfo/$TZ /etc/localtime
        echo "$TZ" > /etc/timezone
        echo "Timezone set to $TZ"
    else
        echo "Environment variable TZ ($TZ) is invalid, ignoring..."
    fi
fi

if [ $PUID -eq 0 ]; then
    echo "Starting as root user"
    exec "$@"
fi

usermod -o -u "$PUID" docker >/dev/null 2>&1
groupmod -o -g "$PGID" docker >/dev/null 2>&1

chown docker:docker /app
chown docker:docker /config
chown docker:docker /data

echo "Starting with UID/GID: $PUID/$PGID"
exec su-exec docker "$@"
