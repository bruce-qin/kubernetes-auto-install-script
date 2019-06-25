# nginx media server with (rtmp、flv、hls、dash)
 [Compile from (nginx-http-flv-module)](https://github.com/winshining/nginx-http-flv-module)\
添加了nginx默认配置，如需自定义，可修改挂载目录\
多媒体文件目录：`/media`\
hls目录：`/media/hls`\
dash目录：`/media/dash`\
html文件目录：`/etc/nginx/html/`

 ## 推流发布
ffmpeg：

    ffmpeg -re -i MEDIA_FILE_NAME -c copy -f flv rtmp://example.com[:port]/appname/streamname
 
 ## 播放
 
 #### HTTP-FLV方式****
 
     http://example.com[:port]/dir?[port=xxx&]app=myapp&stream=mystream
 
 ### 注意
 
 * 如果使用[ffplay](http://www.ffmpeg.org/ffplay.html)命令行方式播放流，那么**必须**为上述的url加上引号，否则url中的参数会被丢弃（有些不太智能的shell会把"&"解释为"后台运行"）。
 
 * 如果使用[flv.js](https://github.com/Bilibili/flv.js)播放流，那么请保证发布的流被正确编码，因为[flv.js](https://github.com/Bilibili/flv.js)**只支持H.264编码的视频和AAC/MP3编码的音频**。
 
 参数`dir`用于匹配http配置块中的location块（更多详情见下文）。
 
 **HTTP默认端口**为**80**, 如果使用了其他端口，必须指定`:port`。
 
 **RTMP默认端口**为**1935**，如果使用了其他端口，必须指定`port=xxx`。
 
 参数`app`用来匹配application块，但是如果请求的`app`出现在多个server块中，并且这些server块有相同的地址和端口配置，那么还需要用匹配主机名的`server_name`配置项来区分请求的是哪个application块，否则，将匹配第一个application块。
 
 参数`stream`用来匹配发布流的streamname。
 ### RTMP方式
 
     rtmp://example.com[:port]/appname/streamname
 
 ### HLS方式
 
     http://example.com[:port]/hls/streamname.m3u8
 
 ### DASH方式
 
     http://example.com[:port]/dash/streamname.mpd