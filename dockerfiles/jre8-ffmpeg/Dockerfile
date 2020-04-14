FROM alpine AS release
#install ffmpeg openjdk
RUN         apk add --no-cache --update openjdk8-jre ffmpeg
#java
ENV JAVA_HOME=/usr/lib/jvm/jre-1.8-openjdk
ENV CLASSPATH=.:$JAVA_HOME/lib
ENV PATH=$PATH:$JAVA_HOME/bin

ENTRYPOINT  ["sh"]
