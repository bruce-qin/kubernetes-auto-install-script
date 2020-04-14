FROM alpine AS release
#install ffmpeg openjdk
RUN         apk add --no-cache --update openjdk14-jdk@testing ffmpeg
#java
ENV JAVA_HOME=/usr/lib/jvm/java-14-openjdk
ENV CLASSPATH=.:$JAVA_HOME/lib
ENV PATH=$PATH:$JAVA_HOME/bin

ENTRYPOINT  ["sh"]
