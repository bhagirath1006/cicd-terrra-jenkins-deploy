FROM eclipse-temurin:21-jre

WORKDIR /app

# Create a minimal Java HTTP server application
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create the Java application inline
RUN cat > Application.java << 'EOF'
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.net.InetSocketAddress;

public class Application {
    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(8081), 0);
        server.createContext("/", exchange -> {
            String response = "Java API is running";
            exchange.sendResponseHeaders(200, response.length());
            exchange.getResponseBody().write(response.getBytes());
            exchange.close();
        });
        server.setExecutor(null);
        server.start();
        System.out.println("Server started on port 8081");
    }
}
EOF

RUN javac Application.java && \
    jar cfe app.jar Application Application.class

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8081/ || exit 1

CMD ["java", "-jar", "app.jar"]
