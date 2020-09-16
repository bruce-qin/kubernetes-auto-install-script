FROM alpine AS release
#install ffmpeg openjdk
RUN         sed -i "s/dl-cdn.alpinelinux.org/mirror.tuna.tsinghua.edu.cn/g" /etc/apk/repositories;\
            apk add --no-cache dmidecode openjdk11-jre tzdata;\
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
