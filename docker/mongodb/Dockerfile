FROM mongo:6-alpine

COPY mongod.conf /etc/mongod.conf

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD mongosh --eval 'db.runCommand("ping")' || exit 1

CMD ["mongod", "--config", "/etc/mongod.conf"]
