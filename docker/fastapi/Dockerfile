FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir fastapi==0.104.1 uvicorn==0.24.0 pydantic==2.5.0 requests==2.31.0 python-multipart==0.0.6

COPY . .

EXPOSE 8002

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8002/docs || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]
