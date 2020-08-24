FROM alpine AS release
#install ffmpeg openjdk
RUN         sed -i "s/dl-cdn.alpinelinux.org/mirror.tuna.tsinghua.edu.cn/g" /etc/apk/repositories;\
            apk add --no-cache --update openjdk8 tzdata ffmpeg;\
            cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;\
            echo "Asia/Shanghai" > /etc/timezone
#java
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
    CLASSPATH=.:$JAVA_HOME/lib \
    PATH=$PATH:$JAVA_HOME/bin \
    TIME_ZONE="Asia/Shanghai" \
    LANG=zh_CN.utf8

ENTRYPOINT  ["sh"]
