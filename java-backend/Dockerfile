FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
# Backend application listens on port 8082
EXPOSE 8082
CMD ["java", "-jar", "app.jar"]