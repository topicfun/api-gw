FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
# A backend alkalmazás futhat 8082-on
EXPOSE 8082
CMD ["java", "-jar", "app.jar"]