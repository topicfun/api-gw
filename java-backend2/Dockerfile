FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
# The second backend application runs on port 8080
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
