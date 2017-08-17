FROM maven:latest as appserver
WORKDIR /usr/src/jpetstore
COPY pom.xml .
RUN mvn -B -f pom.xml dependency:resolve
COPY . .
RUN mvn -B package

FROM tomcat:8-alpine
WORKDIR /usr/local/tomcat/webapps/ROOT
COPY --from=appserver /usr/src/jpetstore/target/jpetstore .
