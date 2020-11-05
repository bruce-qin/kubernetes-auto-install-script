FROM alpine

WORKDIR /app

RUN    apk add --no-cache --update ffmpeg
ADD ./haikuotiankong.mp3 /app

ENV MULITCAST_ADDR=239.12.13.14:2345

ENTRYPOINT ["ffmpeg", \
                    "-re", \
                    "-stream_loop", \
                    "-1", \
                    "-i", \
                    "/app/haikuotiankong.mp3", \
                    "-c:a", \
                    "libmp3lame", \
                    "-b:a", \
                    "128k", \
                    "-f", \
                    "rtp", \
                    "rtp://$MULITCAST_ADDR"]
