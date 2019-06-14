FROM centos:7 AS baseBuild
ARG NGINX_VERSION=1.16.0
ARG NGINX_HTTP_FLV_MODEL_VERSION=1.2.6
ARG PCRE_VERSION=8.43
ARG OPENSSL_VERSION=1.1.1c
ARG ZLIB_VERSION=1.2.11
RUN yum update;\
        yum install -y psmisc \
                wget \
                autoconf \
                automake \
                cmake \
                freetype-devel \
                gcc \
                gcc-c++ \
                libtool \
                make \
                mercurial \
                pkgconfig \
                zlib-devel ;\
        cd /root;\
        wget -O nginx-${NGINX_VERSION}.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz;\
        tar -xzf nginx-${NGINX_VERSION}.tar.gz;\
        cd nginx-${NGINX_VERSION};\
        wget -O nginx-http-flv-module-${NGINX_HTTP_FLV_MODEL_VERSION}.tar.gz https://github.com/winshining/nginx-http-flv-module/archive/v${NGINX_HTTP_FLV_MODEL_VERSION}.tar.gz;\
        tar -xzf nginx-http-flv-module-${NGINX_HTTP_FLV_MODEL_VERSION}.tar.gz;\
        #sed -i "s/\.openssl\///g" ./auto/lib/openssl/conf;\
        wget -O pcre-${PCRE_VERSION}.tar.gz https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz;\
        tar -xzf pcre-${PCRE_VERSION}.tar.gz;\
        wget -O openssl-${OPENSSL_VERSION}.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz;\
        tar -xzf openssl-${OPENSSL_VERSION}.tar.gz;\
        wget -O zlib-${ZLIB_VERSION}.tar.gz http://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz;\
        tar -xzf zlib-${ZLIB_VERSION}.tar.gz;\
        #编译Nginx
        ./configure \
        --with-stream_ssl_module \
        --with-cc-opt=-static \
        --with-threads \
        --with-http_sub_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-stream \
        --with-openssl=./openssl-${OPENSSL_VERSION}\
        --with-pcre=./pcre-${PCRE_VERSION} \
        --with-pcre-jit \
        --with-zlib=./zlib-${ZLIB_VERSION} \
        --add-module=./nginx-http-flv-module-${NGINX_HTTP_FLV_MODEL_VERSION} \
        --prefix=/usr/local/nginx;\
        make -j $(getconf _NPROCESSORS_ONLN);\
        make  install;\
        apk del .build-deps
#http://nginx.org/download/nginx-1.16.0.tar.gz
#https://github.com/winshining/nginx-http-flv-module/archive/v1.2.6.tar.gz
#https://ftp.pcre.org/pub/pcre/pcre2-10.33.tar.gz
#https://www.openssl.org/source/openssl-1.1.1c.tar.gz
#http://www.zlib.net/zlib-1.2.11.tar.gz

FROM alpine:3.9
EXPOSE 1935
EXPOSE 80
EXPOSE 443
COPY --from=baseBuild  /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
RUN chmox +x /usr/local/sbin/nginx && ln -sf /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx
CMD ["nginx", "-g", "daemon off;"]
