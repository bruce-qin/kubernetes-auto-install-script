FROM alpine

ARG SENTINEL_VERSION=1.7.2
ENV LANG=C.UTF-8

RUN apk add --no-cache --update wget openjdk8-jre

RUN wget -O /root/sentinel-dashboard.jar https://github.com/alibaba/Sentinel/releases/download/${SENTINEL_VERSION}/sentinel-dashboard-${SENTINEL_VERSION}.jar

RUN apk del wget

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV CLASSPATH=.:$JAVA_HOME/lib
ENV PATH=$PATH:$JAVA_HOME/bin

ENV SENTINEL_USERNAME sentinel
ENV SENTINEL_PASSWORD sentinel

WORKDIR /root

EXPOSE 8080
EXPOSE 8719

ENTRYPOINT [ "java", "-server", "-Djava.security.egd=file:/dev/./urandom", "-Dcsp.sentinel.dashboard.server=127.0.0.1:8080", "-Dcsp.sentinel.api.port=8719", "-Dproject.name=sentinel-dashboard", "-Dauth.username=${SENTINEL_USERNAME}", "-Dauth.password=${SENTINEL_PASSWORD}",  "-jar", "/root/sentinel-dashboard.jar"]
