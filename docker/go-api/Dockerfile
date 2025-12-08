FROM golang:1.21-alpine AS builder

WORKDIR /app

# Create go.mod file
RUN echo 'module go-api\n\ngo 1.21' > go.mod

# Create main.go with a simple HTTP server
RUN echo 'package main\n\nimport (\n  "fmt"\n  "net/http"\n)\n\nfunc main() {\n  http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {\n    fmt.Fprintf(w, "Go API is running")\n  })\n  http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {\n    fmt.Fprintf(w, "OK")\n  })\n  http.ListenAndServe(":8080", nil)\n}' > main.go

RUN go build -o api .

FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/api .

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["./api"]
