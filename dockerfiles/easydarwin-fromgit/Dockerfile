FROM golang:alpine AS baseBuild
ARG OUT_PUT_DIR=/tmp/build/easydarwin
RUN apk add --no-cache git \
                        gcc \
                        g++ \
                        libtool \
                        make \
                        nodejs \
                        npm \
                        gzip \
                        dos2unix \
                        tar ;\
        go get -u -v github.com/kardianos/govendor;\
        go get -u -v github.com/penggy/gobuild;\
        npm i -g apidoc;\
#        npm i -g rimraf;\
#        npm i -g  readline;\
#        npm i -g @penggy/pack;\
        cd $GOPATH/src/github.com;\
        mkdir EasyDarwin && cd EasyDarwin;\
        git clone https://github.com/EasyDarwin/EasyDarwin.git --depth=1 EasyDarwin;\
        cd EasyDarwin;\
        sed -i "$(sed -n -e '/"build:lin":/=' package.json)c \"build:lin\": \"go build -tags release -tags netgo -ldflags '-extldflags -static -s -w' -o easydarwin\"," package.json;\
        cat package.json;\
        npm run build:lin;\
        dos2unix easydarwin.ini;\
        mkdir -p ${OUT_PUT_DIR};\
        cp -r easydarwin easydarwin.ini  www ${OUT_PUT_DIR}
#        pack tar;\
#        tar -xzf $(ls | grep EasyDarwin-*.tar.gz) -C ${OUT_PUT_DIR}

FROM jrottenberg/ffmpeg:4.1-alpine
ENV LANG C.UTF-8
WORKDIR /
#install easydarwin
#系统登录账号（rtsp推拉流）
ENV DEFAULT_USERNAME admin
#系统登录密码（rtsp推拉流）
ENV DEFAULT_PASSWORD admin
#是否使能向服务器推流或者从服务器播放时验证用户名密码. [注意] 因为服务器端并不保存明文密码，所以推送或者播放时，客户端应该输入密码的md5后的值。
ENV AUTHORIZATION_ENABLE 0
#新的推流器连接时，如果已有同一个推流器（PATH相同）在推流，是否关闭老的推流器。
#如果为0，则不会关闭老的推流器，新的推流器会被响应406错误，否则会关闭老的推流器，新的推流器会响应成功。
ENV CLOSE_OLD 0
#当close_old为1时，是否保留被关闭的推流器对应的播放器。
#如果为0，则原推流器对应的播放器会被断开。否则会被保留下来。注意，如果该选项为1，可能某些播放器会有异常，因为RTP序列可能不一致了。
ENV KEEP_PLAYERS 0
#是否开启推送的同事进行本地存储，开启后则可以进行录像查询与回放。ts文件存储位置/media/hls
ENV SAVE_STREAM_TO_LOCAL 0
COPY --from=0 /tmp/build/easydarwin /easydarwin
RUN {\
        echo '#!/bin/sh';\
        echo 'if [ ! -f "/easydarwin_home" ];then';\
        echo 'EASYDARWIN_HOME=$(dirname $(find /easydarwin -name easydarwin.ini))';\
        echo 'sed -i "s/^ffmpeg_path=.*/ffmpeg_path=\/usr\/local\/bin\/ffmpeg/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'if [[ -n $DEFAULT_USERNAME ]];then';\
        echo '  sed -i "s/^default_username=.*/default_username=$DEFAULT_USERNAME/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n $DEFAULT_PASSWORD ]];then';\
        echo '  sed -i "s/^default_password=.*/default_password=$DEFAULT_PASSWORD/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$AUTHORIZATION_ENABLE" == "1" ];then';\
        echo '  sed -i "s/^authorization_enable=.*/authorization_enable=$AUTHORIZATION_ENABLE/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$CLOSE_OLD" == "1" ];then';\
        echo '  sed -i "s/^close_old=.*/close_old=$CLOSE_OLD/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$KEEP_PLAYERS" == "1" ];then';\
        echo '  sed -i "s/^keep_players=.*/keep_players=$KEEP_PLAYERS/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$SAVE_STREAM_TO_LOCAL" == "1" ];then';\
        echo '  sed -i "s/^save_stream_to_local=.*/keep_players=$SAVE_STREAM_TO_LOCAL/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo '  sed -i "s/^m3u8_dir_path=.*/m3u8_dir_path=\/media\/hls/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'chmod +x $EASYDARWIN_HOME/easydarwin';\
        echo 'echo "$EASYDARWIN_HOME" > /easydarwin_home';\
        echo 'else';\
        echo 'EASYDARWIN_HOME=$(cat /easydarwin_home)';\
        echo 'fi';\
        echo '$EASYDARWIN_HOME/easydarwin';\
        }>/start-easydarwin && chmod +x /start-easydarwin
#暴露容器rtsp端口
EXPOSE 554
#暴露容器http端口
EXPOSE 10008
#ts存储文件位置
RUN mkdir -p /media/hls
VOLUME /media/hls
ENTRYPOINT ["/start-easydarwin"]
