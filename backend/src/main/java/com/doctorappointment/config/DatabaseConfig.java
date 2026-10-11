package com.doctorappointment.config;

import java.net.URI;
import java.net.URISyntaxException;
import javax.sql.DataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

@Configuration
@Profile("!test")
public class DatabaseConfig {

    private static final Logger log = LoggerFactory.getLogger(DatabaseConfig.class);

    @Bean
    @Primary
    public DataSource dataSource(Environment env) {
        String databaseUrl = env.getProperty("DATABASE_URL");
        String mysqlUrl = env.getProperty("MYSQL_URL");
        if ((mysqlUrl == null || mysqlUrl.isBlank()) && databaseUrl != null && databaseUrl.startsWith("mysql://")) {
            mysqlUrl = databaseUrl;
        }

        // 1. Detect MySQL URL format (Railway, Docker, mysql://user:pass@host:port/dbname)
        if (mysqlUrl != null && !mysqlUrl.isBlank() && mysqlUrl.startsWith("mysql://")) {
            try {
                URI uri = new URI(mysqlUrl);
                String host = uri.getHost();
                int port = uri.getPort() == -1 ? 3306 : uri.getPort();
                String path = uri.getPath();
                String userInfo = uri.getUserInfo();
                String username = "";
                String password = "";

                if (userInfo != null && userInfo.contains(":")) {
                    String[] credentials = userInfo.split(":", 2);
                    username = credentials[0];
                    password = credentials[1];
                }

                String jdbcUrl = "jdbc:mysql://" + host + ":" + port + path
                        + "?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                log.info("Configured MySQL datasource from URL for host: {}:{}", host, port);

                return DataSourceBuilder.create()
                        .driverClassName("com.mysql.cj.jdbc.Driver")
                        .url(jdbcUrl)
                        .username(username)
                        .password(password)
                        .build();
            } catch (URISyntaxException e) {
                log.warn("Failed to parse MySQL URL as URI, falling back to default datasource: {}", e.getMessage());
            }
        }

        // 2. Detect PostgreSQL URL format (Render, Neon, postgres:// or postgresql://)
        if (databaseUrl != null && !databaseUrl.isBlank() &&
                (databaseUrl.startsWith("postgres://") || databaseUrl.startsWith("postgresql://"))) {
            try {
                URI uri = new URI(databaseUrl);
                String host = uri.getHost();
                int port = uri.getPort() == -1 ? 5432 : uri.getPort();
                String path = uri.getPath();
                String userInfo = uri.getUserInfo();
                String username = "";
                String password = "";

                if (userInfo != null && userInfo.contains(":")) {
                    String[] credentials = userInfo.split(":", 2);
                    username = credentials[0];
                    password = credentials[1];
                }

                String jdbcUrl = "jdbc:postgresql://" + host + ":" + port + path;
                log.info("Configured PostgreSQL datasource from DATABASE_URL for host: {}:{}", host, port);

                return DataSourceBuilder.create()
                        .driverClassName("org.postgresql.Driver")
                        .url(jdbcUrl)
                        .username(username)
                        .password(password)
                        .build();
            } catch (URISyntaxException e) {
                log.warn("Failed to parse DATABASE_URL as URI, falling back to default datasource: {}", e.getMessage());
            }
        }

        // 2. Standard Spring Boot properties (Local MySQL, Docker, or explicit SPRING_DATASOURCE_URL)
        String url = env.getProperty("spring.datasource.url");
        String username = env.getProperty("spring.datasource.username");
        String password = env.getProperty("spring.datasource.password");
        String driver = env.getProperty("spring.datasource.driver-class-name");

        // If URL starts with postgresql:// or postgres:// without jdbc: prefix, fix it
        if (url != null && (url.startsWith("postgres://") || url.startsWith("postgresql://"))) {
            url = "jdbc:" + url;
        }

        var builder = DataSourceBuilder.create();
        if (driver != null && !driver.isBlank()) {
            builder.driverClassName(driver);
        } else if (url != null && url.contains(":postgresql:")) {
            builder.driverClassName("org.postgresql.Driver");
        } else if (url != null && url.contains(":mysql:")) {
            builder.driverClassName("com.mysql.cj.jdbc.Driver");
        }

        if (url != null) {
            builder.url(url);
        }
        if (username != null) {
            builder.username(username);
        }
        if (password != null) {
            builder.password(password);
        }

        log.info("Configured datasource with URL: {}", url != null ? url.replaceAll(":[^:@]+@", ":****@") : "null");
        return builder.build();
    }
}
