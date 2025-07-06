FROM maven:3.9.7-eclipse-temurin-21-alpine AS build
COPY src ./src
COPY pom.xml .
RUN mvn clean install

FROM amazoncorretto:21 AS run
COPY --from=build target .
ENTRYPOINT ["java", "Dspring.profiles.active=docker", "-jar", "ticketevolution-0.0.1-SNAPSHOT.jar"]
