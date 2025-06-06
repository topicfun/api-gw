FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
# A kliens alkalmazás futhat más porton, pl. 8081-en
EXPOSE 8081
CMD ["java", "-jar", "app.jar"]