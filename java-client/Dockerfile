FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
# The client application can run on another port, e.g., 8081
EXPOSE 8081
CMD ["java", "-jar", "app.jar"]