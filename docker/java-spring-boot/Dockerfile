FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create a simple Java application that doesn't require external dependencies
RUN echo 'public class App { public static void main(String[] args) { System.out.println("Java app running"); } }' > App.java && \
    javac App.java && \
    jar cfe app.jar App App.class

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8081/ || exit 1

CMD ["java", "-jar", "app.jar"]
