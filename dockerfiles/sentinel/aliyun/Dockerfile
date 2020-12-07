FROM justtin/sentinel
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
