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