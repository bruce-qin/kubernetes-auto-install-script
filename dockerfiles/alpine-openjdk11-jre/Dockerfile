FROM alpine AS release
#install ffmpeg openjdk
RUN     apk add --no-cache --update openjdk11-jre tzdata;\
            cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;\
            echo "Asia/Shanghai" > /etc/timezone

ARG JH=/usr/lib/jvm/java-11-openjdk
#java
ENV JAVA_HOME=$JH \
    CLASSPATH=.:$JH/lib \
    PATH=$PATH:$JH/bin \
    TIME_ZONE="Asia/Shanghai" \
    LANG=zh_CN.utf8

ENTRYPOINT  ["sh"]
