FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir Flask==2.3.3 Flask-CORS==4.0.0 requests==2.31.0 Werkzeug==2.3.7 Jinja2==3.1.2 click==8.1.7 itsdangerous==2.1.2

COPY . .

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

CMD ["flask", "run", "--host=0.0.0.0"]
