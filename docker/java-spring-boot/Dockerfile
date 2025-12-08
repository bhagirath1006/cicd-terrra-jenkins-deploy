FROM eclipse-temurin:21-jre

WORKDIR /app

# Create a minimal Spring Boot application jar
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY Application.java .

RUN javac Application.java && \
    jar cfe app.jar Application Application.class

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8081/ || exit 1

CMD ["java", "-jar", "app.jar"]
