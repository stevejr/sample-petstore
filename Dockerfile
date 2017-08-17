FROM tomcat:8-alpine

MAINTAINER Steve Richards "srichards@leftshiftit.com"

ADD ./target/jpetstore /usr/local/tomcat/webapps/ROOT
