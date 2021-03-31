# Dockerfile.ok for a simple Nginx stream replicator

# Separate build stage to keep build dependencies out of our final image
ARG ALPINE_VERSION=alpine
FROM ${ALPINE_VERSION}
ENV LANG C.UTF-8
# Software versions to build
ARG NGINX_VERSION=nginx-1.18.0
ARG NGINX_HTTP_FLV_MODEL_VERSION=1.2.8
ARG PCRE_VERSION=8.44
ARG OPENSSL_VERSION=1.1.1k
ARG ZLIB_VERSION=1.2.11

# Install buildtime dependencies
# Note: We build against LibreSSL instead of OpenSSL, because LibreSSL is already included in Alpine
RUN apk --no-cache add build-base tar \
            gcc \
            libc-dev \
            make \
            openssl-dev \
            pcre-dev \
            zlib-dev \
            linux-headers \
            libxslt-dev \
            gd-dev \
            geoip-dev \
            perl-dev \
            libedit-dev \
            mercurial \
            bash \
            alpine-sdk \
            findutils

# Download sources
# Note: We download our own fork of nginx-rtmp-module which contains some additional enhancements over the original version by arut
RUN mkdir -p /build && \
    wget -O - https://nginx.org/download/${NGINX_VERSION}.tar.gz | tar -zxC /build -f - && \
    mv /build/${NGINX_VERSION} /build/nginx && \
    wget -O - https://github.com/winshining/nginx-http-flv-module/archive/v${NGINX_HTTP_FLV_MODEL_VERSION}.tar.gz | tar -zxC /build -f - && \
    mv /build/nginx-http-flv-module-${NGINX_HTTP_FLV_MODEL_VERSION} /build/nginx-http-flv-module&& \
    wget -O - https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz | tar -zxC /build -f - && \
    mv /build/pcre-${PCRE_VERSION} /build/pcre && \
    wget -O - https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz | tar -zxC /build -f - && \
    mv /build/openssl-${OPENSSL_VERSION} /build/openssl && \
    wget -O - http://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz | tar -zxC /build -f - && \
    mv /build/zlib-${ZLIB_VERSION} /build/zlib

# Build a minimal version of nginx
RUN cd /build/nginx && \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/lock/nginx.lock \
        --http-client-body-temp-path=/tmp/nginx/client-body \
        --user=nginx --group=nginx \
        --with-stream \
        --with-stream_ssl_module \
        --with-threads \
        --with-http_sub_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-openssl=/build/openssl \
        --with-pcre=/build/pcre \
        --with-pcre-jit \
        --with-zlib=/build/zlib \
        --add-module=/build/nginx-http-flv-module && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    cp /build/nginx-http-flv-module/stat.xsl /build/nginx/conf/

# Final image stage
FROM justtin/alpine-ffmpeg

RUN apk --no-cache add nginx-mod-http-image-filter \
                libxslt \
                libedit \
                perl \
                geoip \
                gd

# Set up group and user
#RUN set +e && addgroup -S nginx && \
#    adduser -s /sbin/nologin -G nginx -S -D -H nginx

# Copy files from build stage
COPY --from=0 /build/nginx/conf/ /etc/nginx/
COPY --from=0 /build/nginx/html/ /etc/nginx/html/
COPY --from=0 /build/nginx/objs/nginx /usr/local/sbin/nginx
# Set up config file
COPY nginx.conf /etc/nginx/nginx.conf

# Set up directories
RUN set -e && mkdir -p /etc/nginx/logs/ /var/log/nginx /var/www /tmp/nginx/client-body && \
    chown -R nginx:nginx /var/log/nginx /var/www && \
    chmod -R 775 /var/log/nginx /var/www ;\
    ln -sf /dev/stdout /etc/nginx/logs/access.log && \
    ln -sf /dev/stderr /etc/nginx/logs/error.log ;\
    chmod 444 /etc/nginx/nginx.conf && mkdir -p /media/{hls,dash} ;\
    chmod +x /usr/local/sbin/nginx
# Set up exposed ports
EXPOSE 1935 \
             80 \
             443

#挂载音视频媒体文件 hls:/media/hls dash:/media/dash
VOLUME /media
#自定义nginx配置
VOLUME /etc/nginx/
ENTRYPOINT ["nginx", "-g", "daemon off;"]
CMD []
