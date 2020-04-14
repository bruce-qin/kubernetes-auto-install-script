#ffmpeg
FROM jrottenberg/ffmpeg:4.2-alpine311 AS ffmpeg

FROM alpine:3.11 AS release
#ffmpeg lib
RUN         apk add --no-cache --update libgcc libstdc++ ca-certificates libcrypto1.1 libssl1.1 libgomp expat zlib openjdk8-jdk
#ffmpeg
COPY --from=ffmpeg  /usr/local    /usr/local
ENV     LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib:/usr/lib64:/lib:/lib64
#java
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV CLASSPATH=.:$JAVA_HOME/lib
ENV PATH=$PATH:$JAVA_HOME/bin

ENTRYPOINT  ["sh"]
