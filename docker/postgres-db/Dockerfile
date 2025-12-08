FROM postgres:15-alpine

ENV POSTGRES_DB=app_db
ENV POSTGRES_USER=bhagirath
ENV POSTGRES_PASSWORD=redhat

EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pg_isready -U bhagirath || exit 1

CMD ["postgres"]
