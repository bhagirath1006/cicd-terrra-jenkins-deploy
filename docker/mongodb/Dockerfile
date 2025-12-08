FROM mongo:6

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD mongosh --eval 'db.runCommand("ping")' || exit 1

CMD ["mongod"]
