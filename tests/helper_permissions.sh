#!/usr/bin/env sh
for folder in config data; do
    if [ "$(stat -c "%u" "/${folder}")" -ne "${PUID}" ] && [ 0 -ne "${PUID}" ]; then
        echo "/${folder} UID $(stat -c "%u" "/${folder}") != PUID ${PUID}"
        exit 1
    fi
    if [ "$(stat -c "%g" "/${folder}")" -ne "${PGID}" ] && [ 0 -ne "${PGID}" ]; then
        echo "/${folder} GID $(stat -c "%g" "/${folder}") != PGID ${PGID}"
        exit 1
    fi
    if [ ! -f "/${folder}/.permissions-set" ] && [ 0 -eq "${PUID}" ]; then
        continue
    fi
    if [ "$(stat -c "%u" "/${folder}/.permissions-set")" -ne "${PUID}" ]; then
        echo "/${folder}/.permissions-set UID $(stat -c "%u" "/${folder}/.permissions-set") != PUID ${PUID}"
        exit 1
    fi
    if [ "$(stat -c "%g" "/${folder}/.permissions-set")" -ne "${PGID}" ]; then
        echo "/${folder}/.permissions-set GID $(stat -c "%g" "/${folder}/.permissions-set") != PGID ${PGID}"
        exit 1
    fi
done
