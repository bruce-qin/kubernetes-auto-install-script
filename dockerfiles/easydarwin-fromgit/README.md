# 暴露容器rtsp端口
EXPOSE 554
# 暴露容器http端口
EXPOSE 10008
## 系统登录账号（rtsp推拉流）
ENV DEFAULT_USERNAME admin
## 系统登录密码（rtsp推拉流）
ENV DEFAULT_PASSWORD admin
## 是否使能向服务器推流或者从服务器播放时验证用户名密码. [注意] 因为服务器端并不保存明文密码，所以推送或者播放时，客户端应该输入密码的md5后的值。
ENV AUTHORIZATION_ENABLE 0
## 新的推流器连接时，如果已有同一个推流器（PATH相同）在推流，是否关闭老的推流器。如果为0，则不会关闭老的推流器，新的推流器会被响应406错误，否则会关闭老的推流器，新的推流器会响应成功。
ENV CLOSE_OLD 0
## 当close_old为1时，是否保留被关闭的推流器对应的播放器。如果为0，则原推流器对应的播放器会被断开。否则会被保留下来。注意，如果该选项为1，可能某些播放器会有异常，因为RTP序列可能不一致了。
ENV KEEP_PLAYERS 0
## 是否开启推送的同事进行本地存储，开启后则可以进行录像查询与回放。ts文件存储位置`/home/media/hls`
ENV SAVE_STREAM_TO_LOCAL 0
## rtp udp推送时服务端端口范围
ENV RTPSERVER_UDPORT_RANGE 50000:55000
## 是否启用组播集群
ENV ENABLE_MULTICAST 0
## 推流时执行ffmpeg命令，变量 `{path}`。多个用英文`;`分割。
ENV EASYDARWIN_PUSH_FFMPEG_CMD ""

## 推流时执行ffmpeg命令错误重试次数
ENV EASYDARWIN_CMD_ERROR_REPEAT_TIME
