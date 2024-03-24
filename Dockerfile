FROM arm64v8/eclipse-temurin:17.0.9_9-jdk-focal
VOLUME /tmp
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
