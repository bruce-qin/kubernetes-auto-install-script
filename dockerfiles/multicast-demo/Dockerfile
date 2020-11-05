FROM alpine

WORKDIR /app

RUN    apk add --no-cache --update ffmpeg
ADD ./haikuotiankong.mp3 /app

ENTRYPOINT ["ffmpeg", \
                    "-re", \
                    "-stream_loop", \
                    "-1", \
                    "-i", \
                    "/app/haikuotiankong.mp3", \
                    "-c:a", \
                    "libmp3lame", \
                    "-vn", \
                    "-b:a", \
                    "128k", \
                    "-f", \
                    "rtp"]

CMD ["rtp://239.12.13.14:2345"]
