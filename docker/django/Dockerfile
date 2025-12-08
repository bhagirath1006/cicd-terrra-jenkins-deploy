FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir Django==4.2.7 djangorestframework==3.14.0 django-cors-headers==4.3.1 python-decouple==3.8 gunicorn==21.2.0 psycopg2-binary==2.9.9 requests==2.31.0 Werkzeug==2.3.7

COPY . .

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "wsgi:app"]
