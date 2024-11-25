ARG BASE_IMG
FROM ${BASE_IMG}

ADD user-entrypoint.sh /bin/user-entrypoint
RUN chmod +rx /bin/user-entrypoint && /bin/user-entrypoint --init
ENTRYPOINT ["/bin/user-entrypoint"]

CMD ["sh"]
