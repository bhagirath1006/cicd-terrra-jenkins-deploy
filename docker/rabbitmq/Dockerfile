FROM rabbitmq:3.12-management-alpine

ENV RABBITMQ_DEFAULT_USER=guest
ENV RABBITMQ_DEFAULT_PASS=guest

EXPOSE 5672 15672

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD rabbitmq-diagnostics -q ping || exit 1

CMD ["rabbitmq-server"]
