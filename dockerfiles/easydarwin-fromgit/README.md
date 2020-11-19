# 暴露容器rtsp端口
EXPOSE 554
# 暴露容器http端口
EXPOSE 10008
## 系统登录账号（rtsp推拉流）
ENV DEFAULT_USERNAME admin
## 系统登录密码（rtsp推拉流）
ENV DEFAULT_PASSWORD admin
## 是否启用向服务器推流或者从服务器播放时验证用户名密码. [注意] 因为服务器端并不保存明文密码，所以推送或者播放时，客户端应该输入密码的md5后的值。
ENV LOCAL_AUTHORIZATION_ENABLE 0
## 是否启用远程身份认证，适用于cluster
ENV REMOTE_HTTP_AUTHORIZATION_ENABLE 0
## 身份认证类型`Basic`or`Digest`
ENV AUTHORIZATION_TYPE Digest
## 远程身份认证地址，请求必须返回`0`表示成功，否则则失败
> 请求类型 `POST application/json`:
```json
{
    "authType": "Digest",
    "username": "admin",
    "password": "admin",
    "realm": "rtsp(23435)",
    "nonce": "8fd7c44874480bd6...",
    "uri": "rtsp://192.168.1.76:554/live/123asd",
    "response": "ca29ba3....",
    "requestMethod": "SETUP",
    "sessionType": "player | pusher"
}
```
>为`Basic`时只有`username`和`password`\
>为`Digest`时没有`passord`,认证算法匹配response==MD5(MD5(username:realm:password):nonce:MD5(method:uri))

ENV REMOTE_HTTP_AUTHORIZATION_URL 

## 新的推流器连接时，如果已有同一个推流器（PATH相同）在推流，是否关闭老的推流器。如果为0，则不会关闭老的推流器，新的推流器会被响应406错误，否则会关闭老的推流器，新的推流器会响应成功。
ENV CLOSE_OLD 0
## 当close_old为1时，是否保留被关闭的推流器对应的播放器。如果为0，则原推流器对应的播放器会被断开。否则会被保留下来。注意，如果该选项为1，可能某些播放器会有异常，因为RTP序列可能不一致了。
ENV KEEP_PLAYERS 0
## 当推流不存在时，拉流请求等待时间
ENV STREAM_NOTEXIST_WAIT_SECOND 5
## 是否开启推送的同事进行本地存储，开启后则可以进行录像查询与回放。ts文件存储位置`/home/media/hls`
ENV SAVE_STREAM_TO_LOCAL 0
## rtp udp推送时服务端端口范围
ENV RTPSERVER_UDPORT_RANGE 50000:55000
## 是否启用组播集群
ENV ENABLE_MULTICAST 0
##  组播集群通信绑定网卡
ENV EAYDARWIN_MULTICST_BIND_INF_NAME

## 推流时执行ffmpeg命令，变量 `{path}`。多个用英文`;`分割。所有推流都执行
ENV EASYDARWIN_PUSH_FFMPEG_CMD ""
## path一级路径指定执行ffmpeg命令，如果路径只有一级是key为`__default__`
ENV EASYDARWIN_PUSH_FFMPEG_MAP_CMD_{pathKey}
## 如果没有找到相应的pathKey时运行ffmpeg转码命令
ENV EASYDARWIN_PUSH_FFMPEG_OTHER_CMD
## 推流时执行ffmpeg命令错误重试次数
ENV EASYDARWIN_CMD_ERROR_REPEAT_TIME

## 开始拉流时触发api调用
ENV EASYDARWIN_REST_API_ON_PLAY
## 停止拉流时触发api调用
ENV EASYDARWIN_REST_API_ON_STOP
## 开始推流时触发api调用
ENV EASYDARWIN_REST_API_ON_PUBLISH
## 停止推流时触发api调用
ENV EASYDARWIN_REST_API_ON_TEARDOWN

## 是否启用http音频拉流
ENV ENABLE_HTTP_AUDIO_STREAM
## http音频拉流端口
ENV HTTP_AUDIO_STREAM_PORT
## 是否启用http-hsl视频拉流
ENV ENABLE_HTTP_VIDEO_STREAM
## http-hls视频拉流监听端口
ENV HTTP_VIDEO_STREAM_PORT
## nginx rtmp-hls文件存储目录
ENV NGINX_RTMP_HLS_DIR_MAP
