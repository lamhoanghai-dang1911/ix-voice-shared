# Stage 1: Build JAR using Maven and Java 21
FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /build

COPY pom.xml .
# Cache dependencies
RUN mvn dependency:go-offline -B || true

COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Minimal Production JRE Runtime
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Add non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /build/target/*.jar app.jar

RUN mkdir -p /app/data/storage && chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

ENV JAVA_TOOL_OPTIONS="-XX:+UseZGC -XX:+ZGenerational"
ENV STORAGE_LOCAL_DIR=/app/data/storage

ENTRYPOINT ["java", "-jar", "app.jar"]
