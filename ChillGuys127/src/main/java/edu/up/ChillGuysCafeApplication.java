package edu.up;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan("edu.up.model")
@EnableJpaRepositories("edu.up.repository")
public class ChillGuysCafeApplication {
    public static void main(String[] args) {
        SpringApplication.run(ChillGuysCafeApplication.class, args);
    }
} 