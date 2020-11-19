FROM golang:alpine AS baseBuild
ARG OUT_PUT_DIR=/tmp/build/easydarwin
WORKDIR /app
RUN apk add --no-cache git \
                        gcc \
                        g++ \
                        nodejs \
                        npm \
                        dos2unix ; \
        git clone https://github.com/bruce-qin/EasyDarwin.git --depth=1 EasyDarwin;\
        cd EasyDarwin;\
        go get -u;\
        npm run build:lin;\
        dos2unix easydarwin.ini;\
        mkdir -p ${OUT_PUT_DIR};\
        cp -r easydarwin easydarwin.ini  www ${OUT_PUT_DIR}

##二阶段 发布镜像
FROM alpine
ENV LANG C.UTF-8
WORKDIR /app
#install easydarwin
ENV \
    #系统登录账号（rtsp推拉流）
    DEFAULT_USERNAME=admin \
    #系统登录密码（rtsp推拉流）
    DEFAULT_PASSWORD=admin \
    #是否使能向服务器推流或者从服务器播放时验证用户名密码. [注意] 因为服务器端并不保存明文密码，所以推送或者播放时，客户端应该输入密码的md5后的值。
    AUTHORIZATION_ENABLE=0 \
    #新的推流器连接时，如果已有同一个推流器（PATH相同）在推流，是否关闭老的推流器。
    #如果为0，则不会关闭老的推流器，新的推流器会被响应406错误，否则会关闭老的推流器，新的推流器会响应成功。
    CLOSE_OLD=0 \
    #当close_old为1时，是否保留被关闭的推流器对应的播放器。
    #如果为0，则原推流器对应的播放器会被断开。否则会被保留下来。注意，如果该选项为1，可能某些播放器会有异常，因为RTP序列可能不一致了。
    KEEP_PLAYERS=0 \
    #是否开启推送的同事进行本地存储，开启后则可以进行录像查询与回放。ts文件存储位置/media/hls
    SAVE_STREAM_TO_LOCAL=0 \
    #rtp udp推送时服务端端口范围
    RTPSERVER_UDPORT_RANGE=50000:55000 \
    #是否启用集群
    ENABLE_MULTICAST=1 \
    #推流时执行ffmpeg命令错误重试次数
    EASYDARWIN_CMD_ERROR_REPEAT_TIME=5 \
    #启用组播集群时绑定网卡
    EAYDARWIN_MULTICST_BIND_INF_NAME=''
COPY --from=0 /tmp/build/easydarwin /app/easydarwin
RUN apk add --no-cache tzdata ffmpeg ;\
        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ;\
        rm -rf /usr/share/zoneinfo/ ;\
        echo "Asia/Shanghai" > /etc/timezone ;\
        {\
        echo '#!/bin/sh';\
        echo 'if [ ! -f "/app/easydarwin_home" ];then';\
        echo 'EASYDARWIN_HOME=$(dirname $(find /app/easydarwin -name easydarwin.ini))';\
        echo 'sed -i "s/^ffmpeg_path=.*/ffmpeg_path=\/usr\/bin\/ffmpeg/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'if [[ -n "$DEFAULT_USERNAME" ]];then';\
        echo '  sed -i "s/^default_username=.*/default_username=$DEFAULT_USERNAME/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$DEFAULT_PASSWORD" ]];then';\
        echo '  sed -i "s/^default_password=.*/default_password=$DEFAULT_PASSWORD/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$LOCAL_AUTHORIZATION_ENABLE" == "1" ];then';\
        echo '  sed -i "s/^local_authorization_enable=.*/local_authorization_enable=$LOCAL_AUTHORIZATION_ENABLE/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$REMOTE_HTTP_AUTHORIZATION_ENABLE" == "1" ];then';\
        echo '  sed -i "s/^remote_http_authorization_enable=.*/remote_http_authorization_enable=$REMOTE_HTTP_AUTHORIZATION_ENABLE/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$AUTHORIZATION_TYPE" ]];then';\
        echo '  sed -i "s/^authorization_type=.*/authorization_type=$AUTHORIZATION_TYPE/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$REMOTE_HTTP_AUTHORIZATION_URL" ]];then';\
        echo '  sed -i "s/^remote_http_authorization_url=.*/remote_http_authorization_url=${REMOTE_HTTP_AUTHORIZATION_URL//\//\\\/}/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$EASYDARWIN_REST_API_ON_PLAY" ]];then';\
        echo '  sed -i "s/^on_play=.*/on_play=${EASYDARWIN_REST_API_ON_PLAY//\//\\\/}/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$EASYDARWIN_REST_API_ON_STOP" ]];then';\
        echo '  sed -i "s/^on_stop=.*/on_stop=${EASYDARWIN_REST_API_ON_STOP//\//\\\/}/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$EASYDARWIN_REST_API_ON_PUBLISH" ]];then';\
        echo '  sed -i "s/^on_publish=.*/on_publish=${EASYDARWIN_REST_API_ON_PUBLISH//\//\\\/}/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$EASYDARWIN_REST_API_ON_TEARDOWN" ]];then';\
        echo '  sed -i "s/^on_teardown=.*/on_teardown=${EASYDARWIN_REST_API_ON_TEARDOWN//\//\\\/}/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$ENABLE_HTTP_AUDIO_STREAM" ]];then';\
        echo '  sed -i "s/^enable_http_audio_stream=.*/enable_http_audio_stream=$ENABLE_HTTP_AUDIO_STREAM/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$HTTP_AUDIO_STREAM_PORT" ]];then';\
        echo '  sed -i "s/^http_audio_stream_port=.*/http_audio_stream_port=$HTTP_AUDIO_STREAM_PORT/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$ENABLE_HTTP_VIDEO_STREAM" ]];then';\
        echo '  sed -i "s/^enable_http_video_stream=.*/enable_http_video_stream=$ENABLE_HTTP_VIDEO_STREAM/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$HTTP_VIDEO_STREAM_PORT" ]];then';\
        echo '  sed -i "s/^http_video_stream_port=.*/http_video_stream_port=$HTTP_VIDEO_STREAM_PORT/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$NGINX_RTMP_HLS_DIR_MAP" ]];then';\
        echo '  sed -i "s/^nginx_rtmp_hls_dir_map=.*/nginx_rtmp_hls_dir_map=${NGINX_RTMP_HLS_DIR_MAP//\//\\\/}/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$CLOSE_OLD" == "1" ];then';\
        echo '  sed -i "s/^close_old=.*/close_old=$CLOSE_OLD/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$KEEP_PLAYERS" == "1" ];then';\
        echo '  sed -i "s/^keep_players=.*/keep_players=$KEEP_PLAYERS/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$STREAM_NOTEXIST_WAIT_SECOND" ]];then';\
        echo '  sed -i "s/^stream_notexist_wait_second=.*/stream_notexist_wait_second=$STREAM_NOTEXIST_WAIT_SECOND/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$RTPSERVER_UDPORT_RANGE" ]];then';\
        echo '  sed -i "s/^rtpserver_udport_range=.*/rtpserver_udport_range=$RTPSERVER_UDPORT_RANGE/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$ENABLE_MULTICAST" ]];then';\
        echo '  sed -i "s/^enable_multicast=.*/enable_multicast=$ENABLE_MULTICAST/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [[ -n "$EAYDARWIN_MULTICST_BIND_INF_NAME" ]];then';\
        echo '  sed -i "s/^multicast_svc_bind_inf=.*/multicast_svc_bind_inf=$EAYDARWIN_MULTICST_BIND_INF_NAME/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'if [ "$SAVE_STREAM_TO_LOCAL" == "1" ];then';\
        echo '  sed -i "s/^save_stream_to_local=.*/keep_players=$SAVE_STREAM_TO_LOCAL/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo '  sed -i "s/^m3u8_dir_path=.*/m3u8_dir_path=\/home\/media\/hls/g" $EASYDARWIN_HOME/easydarwin.ini';\
        echo 'fi';\
        echo 'chmod +x $EASYDARWIN_HOME/easydarwin';\
        echo 'echo "$EASYDARWIN_HOME" > /app/easydarwin_home';\
        echo 'else';\
        echo 'EASYDARWIN_HOME=$(cat /app/easydarwin_home)';\
        echo 'fi';\
        echo '$EASYDARWIN_HOME/easydarwin';\
        }>/app/start-easydarwin && chmod +x /app/start-easydarwin;\
        #ts存储文件位置
        mkdir -p /home/media/hls
#暴露容器rtsp端口
EXPOSE 554
#暴露容器http端口
EXPOSE 10008
VOLUME /home/media/hls
ENTRYPOINT ["/app/start-easydarwin"]
