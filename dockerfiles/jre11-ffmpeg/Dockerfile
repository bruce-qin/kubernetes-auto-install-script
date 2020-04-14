FROM adoptopenjdk:11-jre-hotspot as java
FROM jrottenberg/ffmpeg:4.2-alpine311

COPY --from=java /opt/java/openjdk  /opt/java/openjdk
ENV     JAVA_HOME=/opt/java/openjdk
ENV     PATH=$PATH:$JAVA_HOME/bin
ENV     LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib:/usr/lib64:/lib:/lib64

CMD         ["--help"]
ENTRYPOINT  ["ffmpeg"]
