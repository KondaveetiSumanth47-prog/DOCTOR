# -------------------------------------------------------------
# Root Dockerfile for Monorepo Cloud Deployment (Render / Railway)
# -------------------------------------------------------------
FROM eclipse-temurin:25-jdk AS builder
WORKDIR /app

# Copy Maven wrapper and pom.xml from backend/
COPY backend/.mvn/ .mvn/
COPY backend/mvnw backend/pom.xml ./

# Ensure maven wrapper is executable
RUN chmod +x mvnw

# Download dependencies offline
RUN ./mvnw dependency:go-offline -B

# Copy backend source code
COPY backend/src/ ./src/

# Package the Spring Boot JAR
RUN ./mvnw clean package -DskipTests -B

# -------------------------------------------------------------
# Stage 2: Minimal runtime image with Eclipse Temurin JRE 25
# -------------------------------------------------------------
FROM eclipse-temurin:25-jre AS runner
WORKDIR /app

# Create a non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Copy the generated executable JAR from builder stage
COPY --from=builder --chown=appuser:appuser /app/target/*.jar app.jar

ENV PORT=10000
ENV SESSION_COOKIE_SAMESITE=none
ENV SESSION_COOKIE_SECURE=true
EXPOSE 10000

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
