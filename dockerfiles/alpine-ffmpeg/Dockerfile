FROM alpine
ENV LANG C.UTF-8
RUN apk add --no-cache tzdata ffmpeg ;\
        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ;\
        rm -rf /usr/share/zoneinfo/ ;\
        echo "Asia/Shanghai" > /etc/timezone

ENTRYPOINT ["ffmpeg"]
CMD ["-version"]
