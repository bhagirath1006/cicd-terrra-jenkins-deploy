FROM postgres:15-alpine

ENV POSTGRES_DB=app_db
ENV POSTGRES_USER=bhagirath
ENV POSTGRES_PASSWORD=redhat

COPY init-scripts/ /docker-entrypoint-initdb.d/

EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pg_isready -U app_user || exit 1

CMD ["postgres"]
