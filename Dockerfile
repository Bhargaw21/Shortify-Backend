# ---------- Stage 1: Build ----------
    FROM eclipse-temurin:23-jdk AS build

    # Set working directory
    WORKDIR /app
    
    # Copy Maven wrapper and POM to leverage caching
    COPY mvnw .
    COPY .mvn/ .mvn/
    COPY pom.xml .
    
    # Make mvnw executable
    RUN chmod +x mvnw
    
    # Pre-download dependencies
    RUN ./mvnw dependency:go-offline -B
    
    # Copy source code and package the application
    COPY src ./src
    RUN ./mvnw clean package -DskipTests
    
    # ---------- Stage 2: Runtime ----------
    FROM eclipse-temurin:23-jre
    
    # Set working directory
    WORKDIR /app
    
    # Copy the packaged JAR file from the build stage
    COPY --from=build /app/target/*.jar app.jar
    
    # Expose port 8080 (used by Spring Boot)
    EXPOSE 8080
    
    # Run the application
    ENTRYPOINT ["java", "-jar", "/app/app.jar"]
    