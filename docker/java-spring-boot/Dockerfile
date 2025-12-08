FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/* || true

# Create a simple Java application that doesn't require external dependencies
RUN echo 'public class App { public static void main(String[] args) { System.out.println("Java app running"); } }' > App.java && \
    javac App.java && \
    jar cfe app.jar App App.class

FROM eclipse-temurin:21-jre-alpine

WORKDIR /app
COPY --from=0 /app/app.jar .

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8081/ || exit 1

CMD ["java", "-jar", "app.jar"]
