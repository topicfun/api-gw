FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
# A második backend alkalmazás 8083-as porton fut
EXPOSE 8083
CMD ["java", "-jar", "app.jar"]
