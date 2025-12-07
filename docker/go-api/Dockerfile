FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o api .

FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/api .

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["./api"]
