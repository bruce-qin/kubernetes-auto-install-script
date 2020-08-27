FROM alpine

ARG SENTINEL_VERSION=1.8.0
ENV LANG=C.UTF-8

RUN apk add --no-cache --update wget openjdk8-jre tzdata ;\
        wget -O /root/sentinel-dashboard.jar https://github.com/alibaba/Sentinel/releases/download/${SENTINEL_VERSION}/sentinel-dashboard-${SENTINEL_VERSION}.jar ;\
        apk del wget ;\
        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ;\
        echo "Asia/Shanghai" > /etc/timezone

ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
    CLASSPATH=.:$JAVA_HOME/lib \
    PATH=$PATH:$JAVA_HOME/bin \
    TIME_ZONE="Asia/Shanghai" \
    LANG=zh_CN.utf8

ENV SENTINEL_USERNAME sentinel
ENV SENTINEL_PASSWORD sentinel

WORKDIR /root

EXPOSE 8080
EXPOSE 8719

ENTRYPOINT [ "java", \
                    "-server", \
                    "-Djava.security.egd=file:/dev/./urandom", \
                    "-Dcsp.sentinel.dashboard.server=127.0.0.1:8080", \
                    "-Dcsp.sentinel.api.port=8719", \
                    "-Dproject.name=sentinel-dashboard", \
                    "-Dauth.username=${SENTINEL_USERNAME}", \
                    "-Dauth.password=${SENTINEL_PASSWORD}",  \
                    "-jar", \
                    "/root/sentinel-dashboard.jar"]

CMD [""]
