FROM alpine AS release

ARG GLIBC_BASE_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download
ARG GLIBC_PACKAGE_VERSION=2.33-r0

ARG ARCHLINUX_BASE_URL=https://archive.archlinux.org/packages
ARG GCC_LIBS_VERSION=10.2.0-6
ARG ZLIB_VERSION=1.2.11-4

ARG GRAGONWELL_BASE_URL=https://github.com/alibaba/dragonwell11/releases/download
ARG DRAGONWELL_VERSION=11.0.10.5
ARG JAVA_BRANCH=11.0.10
ARG JH=/opt/java

ENV JAVA_HOME=$JH  \
        CLASSPATH=.:${JH}/lib \
        PATH=$JH/bin:$PATH  \
        TIME_ZONE="Asia/Shanghai" \
        LANG=zh_CN.UTF-8


#install tzdata
RUN     apk add --no-cache tzdata dmidecode \
            cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;\
            echo "Asia/Shanghai" > /etc/timezone

#====================
# Install GNU Libc
#====================

RUN apk add --no-cache --virtual=build-dependencies wget \
    && ALPINE_GLIBC_BASE_URL="${GLIBC_BASE_URL}/${GLIBC_PACKAGE_VERSION}" \
    && ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-${GLIBC_PACKAGE_VERSION}.apk" \
    && ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-${GLIBC_PACKAGE_VERSION}.apk" \
    && ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-${GLIBC_PACKAGE_VERSION}.apk" \
    && cd /tmp \
    && wget -q -O "/etc/apk/keys/sgerrand.rsa.pub" "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" \
    && wget "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_BASE_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_BIN_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_BASE_URL}/${ALPINE_GLIBC_I18N_PACKAGE_FILENAME}" \
    && apk add --no-cache \
        "${ALPINE_GLIBC_BASE_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_BIN_PACKAGE_FILENAME}" \
        "${ALPINE_GLIBC_I18N_PACKAGE_FILENAME}" \
    && /usr/glibc-compat/bin/localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 \
    && apk del build-dependencies wget\
    && rm -rf /etc/apk/keys/sgerrand.rsa.pub \
    && rm -rf /tmp/*

#==============
# Install gcc-libs & zlib
#==============

RUN apk add --no-cache --virtual=build-dependencies binutils xz zstd wget\
    && cd /tmp \
    && mkdir /tmp/gcc \
    && wget "${ARCHLINUX_BASE_URL}/g/gcc-libs/gcc-libs-${GCC_LIBS_VERSION}-x86_64.pkg.tar.zst" -O gcc-libs.tar.zst \
    && zstd -d /tmp/gcc-libs.tar.zst --output-dir-flat /tmp \
    && tar -xf /tmp/gcc-libs.tar -C /tmp/gcc \
    && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
    && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
    && mkdir /tmp/zlib \
    && wget "${ARCHLINUX_BASE_URL}/z/zlib/zlib-1%3A${ZLIB_VERSION}-x86_64.pkg.tar.xz" -O zlib.pkg.tar.xz\
    && tar xvJf zlib.pkg.tar.xz -C /tmp/zlib \
    && mv /tmp/zlib/usr/lib/libz.so* /usr/glibc-compat/lib \
    && apk del build-dependencies xz zstd wget\
    && rm -rf /tmp/*


#====================
# Install dragonwell jre
#====================
RUN apk add --no-cache wget \
    && mkdir -p $JH \
    && wget -O - "${GRAGONWELL_BASE_URL}/dragonwell-${DRAGONWELL_VERSION}_jdk-${JAVA_BRANCH}-ga/Alibaba_Dragonwell_${DRAGONWELL_VERSION}_linux_x64.tar.gz" | tar -zxC /tmp -f - \
    && mv /tmp/$(ls /tmp)/* $JH \
    && ln -s ${JAVA_HOME}/bin/* /usr/bin/ \
    && apk del wget\
    && rm -rf /tmp/* \
    && rm -rf ${JAVA_HOME}/lib/src.zip ${JAVA_HOME}/include ${JAVA_HOME}/jmods  ${JAVA_HOME}/man \
    && java -version

ENTRYPOINT  ["sh"]
