FROM tomcat:8-alpine

WORKDIR /usr/local/tomcat/webapps/ROOT

COPY ./target/jpetstore .
