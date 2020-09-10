FROM alpine AS release
#install ffmpeg openjdk
RUN     apk add --no-cache openjdk8-jre tzdata;\
            cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;\
            echo "Asia/Shanghai" > /etc/timezone
#java
ARG JH=/usr/lib/jvm/java-1.8-openjdk
ENV JAVA_HOME=$JH \
    CLASSPATH=.:$JH/lib \
    PATH=$PATH:$JH/bin \
    TIME_ZONE="Asia/Shanghai" \
    LANG=zh_CN.utf8

ENTRYPOINT  ["sh"]
