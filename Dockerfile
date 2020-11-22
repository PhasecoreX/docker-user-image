ARG BASE_IMG
FROM ${BASE_IMG} as builder

ADD https://github.com/ncopa/su-exec/archive/212b75144bbc06722fbd7661f651390dc47a43d1.tar.gz /

RUN apt-get update && \
    apt-get install -y --no-install-recommends make gcc libc6-dev
    
RUN tar xvzf 212b75144bbc06722fbd7661f651390dc47a43d1.tar.gz

RUN cd su-exec-* && \
    make su-exec && \
    mv su-exec /



FROM ${BASE_IMG}

COPY --from=builder /su-exec /bin/su-exec

RUN set -eux; \
# add user and group
    groupadd -f -g 1000 docker; \
    useradd --no-log-init --shell /bin/bash -u 1000 -g 1000 -d /config -o -c "" -m docker; \
    mkdir -p \
        /config \
        /data; \
# add timezone functionality if missing
    if [ ! -d /usr/share/zoneinfo ]; then \
        apt-get update; \
        apt-get install -y --no-install-recommends tzdata; \
        rm -rf /var/lib/apt/lists/*; \
    fi; \
# make sure su-exec is working
    su-exec docker true

COPY user-entrypoint.sh /bin/user-entrypoint

ENTRYPOINT ["user-entrypoint"]

CMD ["bash"]
