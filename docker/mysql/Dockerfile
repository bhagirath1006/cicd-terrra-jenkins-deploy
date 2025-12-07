FROM mysql:8.0

ENV MYSQL_DATABASE=app_db
ENV MYSQL_ROOT_PASSWORD=changeme
ENV MYSQL_USER=app_user
ENV MYSQL_PASSWORD=changeme

COPY init-scripts/ /docker-entrypoint-initdb.d/

EXPOSE 3306

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD mysqladmin ping -u root -p$MYSQL_ROOT_PASSWORD || exit 1

CMD ["mysqld"]
