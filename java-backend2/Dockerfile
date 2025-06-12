FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
# A második backend alkalmazás 8080-as porton fut
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
