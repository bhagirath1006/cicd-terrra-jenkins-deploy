package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

@RestController
class ApiController {
    @GetMapping("/")
    public String home() {
        return "Java Spring Boot API is running";
    }

    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}
