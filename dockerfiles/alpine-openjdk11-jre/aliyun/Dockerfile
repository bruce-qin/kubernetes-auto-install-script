FROM alpine AS release

ARG GLIBC_BASE_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download
ARG GLIBC_PACKAGE_VERSION=2.32-r0

ARG GRAGONWELL_BASE_URL=https://github.com/alibaba/dragonwell11/releases/download
ARG DRAGONWELL_VERSION=11.0.8.3
ARG JAVA_BRANCH=11.0.8
ARG JH=/opt/java

ENV JAVA_HOME=$JH  \
        CLASSPATH=.:${JH}/lib \
        PATH=$JH/bin:$PATH  \
        TIME_ZONE="Asia/Shanghai" \
        LANG=zh_CN.UTF-8


#install tzdata
RUN     apk add --no-cache tzdata dmidecode zlib libgcc;\
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
    && apk del build-dependencies \
    && rm -rf /etc/apk/keys/sgerrand.rsa.pub \
    && rm -rf /tmp/*

#====================
# Install dragonwell jre
#====================
RUN apk add --no-cache --virtual=build-dependencies wget \
    && mkdir -p $JH \
    && wget -O - "${GRAGONWELL_BASE_URL}/dragonwell-${DRAGONWELL_VERSION}_jdk-${JAVA_BRANCH}-ga/OpenJDK11U-jdk_x64_linux_dragonwell_dragonwell-${DRAGONWELL_VERSION}_jdk-${JAVA_BRANCH}-ga.tar.gz" | tar -zxC /tmp -f - \
    && mv /tmp/$(ls /tmp)/* $JH \
    && ln -s ${JAVA_HOME}/bin/* /usr/bin/ \
    && apk del build-dependencies \
    && rm -rf /tmp/* \
    && rm -f ${JAVA_HOME}/lib/src.zip \
    && java -version

ENTRYPOINT  ["sh"]
