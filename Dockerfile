FROM tomcat:8-alpine

ARG BUILD_DATE

ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="git@github.com:stevejr/sample-petstore.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0" \
      org.label-schema.owner="srichards"

WORKDIR /usr/local/tomcat/webapps/ROOT

COPY ./target/jpetstore .
