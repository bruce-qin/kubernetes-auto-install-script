FROM jrottenberg/ffmpeg:4.1-alpine
ENV LANG C.UTF-8

RUN {\
        apk upgrade;
        apk add --no-cache service
        }
ADD /easydarwin /easydarwin/
#系统登录账号（rtsp推拉流）
ENV DEFAULT_USERNAME admin
#系统登录密码（rtsp推拉流）
ENV DEFAULT_PASSWORD admin
#是否使能向服务器推流或者从服务器播放时验证用户名密码. [注意] 因为服务器端并不保存明文密码，所以推送或者播放时，客户端应该输入密码的md5后的值。
ENV AUTHORIZATION_ENABLE 0
RUN {\
        echo '#!/bin/sh';\
        echo 'EASYDARWIN_HOME=$(dirname $(find /easydarwin/ -name easydarwin.ini))';\
        echo 'chmod +x $EASYDARWIN_HOME/easydarwin';\
         echo 'chmod +x $EASYDARWIN_HOME/start.sh';\
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
        echo '$EASYDARWIN_HOME/start.sh';\
        }>/start-easydarwin && chmod +x /start-easydarwin
#暴露容器rtsp端口
EXPOSE 554
#暴露容器http端口
EXPOSE 10008
ENTRYPOINT ["/start-easydarwin"]