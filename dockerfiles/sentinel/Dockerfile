FROM justtin/alpine-openjdk8-jre

ARG SENTINEL_VERSION=1.8.1

RUN apk  add --no-cache  wget \
        && wget -O /root/sentinel-dashboard.jar "https://github.com/alibaba/Sentinel/releases/download/${SENTINEL_VERSION}/sentinel-dashboard-${SENTINEL_VERSION}.jar" \
        && apk del wget

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
