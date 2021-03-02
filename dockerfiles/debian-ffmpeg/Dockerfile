#FROM debian:buster-slim
FROM debian:buster
RUN apt update ;\
    apt install -y ffmpeg ;\
    rm -rf /var/lib/apt/lists/ ;\
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ;\
    echo "Asia/Shanghai" > /etc/timezone

ENTRYPOINT ["ffmpeg"]
CMD ["-version"]
