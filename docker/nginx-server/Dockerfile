FROM nginx:alpine

# Create default nginx configuration
RUN printf 'user nginx;\nworker_processes auto;\nerror_log /var/log/nginx/error.log warn;\npid /var/run/nginx.pid;\nevents {\n  worker_connections 1024;\n}\nhttp {\n  include /etc/nginx/mime.types;\n  default_type application/octet-stream;\n  access_log /var/log/nginx/access.log;\n  sendfile on;\n  keepalive_timeout 65;\n  server {\n    listen 80;\n    location / {\n      return 200 "Nginx is running\n";\n      add_header Content-Type text/plain;\n    }\n    location /health {\n      return 200 "OK\n";\n      add_header Content-Type text/plain;\n    }\n  }\n}\n' > /etc/nginx/nginx.conf

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
