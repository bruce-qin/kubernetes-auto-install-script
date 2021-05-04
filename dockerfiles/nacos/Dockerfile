#阶段一 修改mysql数据库连接版本 并构建

FROM alpine AS build

ARG NACOS_VERSION=2.0.1
ARG SPRING_BOOT_VERSION=2.4.5
ARG MYSQL_VERSION=8.0.24
ARG MINA_IO_VERSION=2.1.4
ARG TOMCAT_EMBED_JASPER_VERSION=9.0.45
ARG PROTOC_VERSION=3.15.8
ARG GRPC_JAVA_VERSION=1.37.0
ARG PROTO_GOOGLE_COMMON_PROTOS_VERSION=2.1.0
ARG GSON_VERSION=2.8.6

RUN apk add --no-cache wget openjdk8 maven tar protoc ;\
    apk add --no-cache --update --repository http://nl.alpinelinux.org/alpine/edge/testing grpc-java
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV CLASSPATH=.:$JAVA_HOME/lib
ENV PATH=$PATH:$JAVA_HOME/bin


WORKDIR /tmp
RUN  wget https://github.com/alibaba/nacos/archive/refs/tags/${NACOS_VERSION}.tar.gz ;\
        tar -xzf ${NACOS_VERSION}.tar.gz

RUN cd nacos-${NACOS_VERSION}; \
        sed -i "$(sed -n -e '/<spring-boot-dependencies.version>/=' pom.xml)s/<spring-boot-dependencies.version>.*/<spring-boot-dependencies.version>${SPRING_BOOT_VERSION}<\/spring-boot-dependencies.version>/g" pom.xml;\
        sed -i "$(sed -n -e '/<mysql-connector-java.version>/=' pom.xml)s/<mysql-connector-java.version>.*/<mysql-connector-java.version>${MYSQL_VERSION}<\/mysql-connector-java.version>/g" pom.xml;\
        sed -i "$(sed -n -e '/<mina-core.version>/=' pom.xml)s/<mina-core.version>.*/<mina-core.version>${MINA_IO_VERSION}<\/mina-core.version>/g" pom.xml;\
        sed -i "$(sed -n -e '/<tomcat-embed-jasper.version>/=' pom.xml)s/<tomcat-embed-jasper.version>.*/<tomcat-embed-jasper.version>${TOMCAT_EMBED_JASPER_VERSION}<\/tomcat-embed-jasper.version>/g" pom.xml;\
	sed -i "$(sed -n -e '/<protobuf-java.version>/=' pom.xml)s/<protobuf-java.version>.*/<protobuf-java.version>${PROTOC_VERSION}<\/protobuf-java.version>/g" pom.xml;\
	sed -i "$(sed -n -e '/<grpc-java.version>/=' pom.xml)s/<grpc-java.version>.*/<grpc-java.version>${GRPC_JAVA_VERSION}<\/grpc-java.version>/g" pom.xml;\
	sed -i "$(sed -n -e '/<proto-google-common-protos.version>/=' pom.xml)s/<proto-google-common-protos.version>.*/<proto-google-common-protos.version>${PROTO_GOOGLE_COMMON_PROTOS_VERSION}<\/proto-google-common-protos.version>/g" pom.xml;\
        # 更新grpc后gson作用域变成了runtime了，需要更新依赖，不然编译不过
	sed -i "$(($(sed -n  -e '/<dependencies>/=' ./client/pom.xml)+1))i\\\t<dependency>\n\t\t<groupId>com.google.code.gson</groupId>\n\t\t<artifactId>gson</artifactId>\n\t\t<version>${GSON_VERSION}</version>\n\t</dependency>" ./client/pom.xml;\
	sed -i "/<pluginArtifact>/d" ./consistency/pom.xml ;\
        sed -i "/<\/pluginArtifact>/d" ./consistency/pom.xml ;\
        sed -i "/<pluginArtifact>/d" ./istio/pom.xml ;\
        sed -i "/<\/pluginArtifact>/d" ./istio/pom.xml ;\
        mvn -Prelease-nacos -Dmaven.test.skip=true clean install -DprotocExecutable=protoc -DpluginExecutable=protoc-gen-grpc-java

#阶段二 拉取nacos官方镜像
FROM nacos/nacos-server:2.0.1 AS standard

RUN SED_LINE=$(sed -n -e '/DEFAULT_SEARCH_LOCATIONS=/=' ./bin/docker-startup.sh); \
        echo "fix sed line: ${SED_LINE}"; \
        sed -i "${SED_LINE}s/file:/optional:file:/g" ./bin/docker-startup.sh ; \
        sed -i "${SED_LINE}s/classpath:/optional:classpath:/g" ./bin/docker-startup.sh

#阶段三 重新发布
FROM  justtin/alpine-openjdk8-jre AS release

ARG NACOS_VERSION=2.0.1


ENV MODE="cluster" \
        PREFER_HOST_MODE="ip"\
        BASE_DIR="/home/nacos" \
        CLASSPATH=".:/home/nacos/conf:$CLASSPATH" \
        CLUSTER_CONF="/home/nacos/conf/cluster.conf" \
        FUNCTION_MODE="all" \
        NACOS_USER="nacos" \
        JVM_XMS="384m" \
        JVM_XMX="1g" \
        JVM_MS="128m" \
        JVM_MMS="320m" \
        JVM_XMN="256m" \
        NACOS_DEBUG="n" \
        JAVA="java" \
        TOMCAT_ACCESSLOG_ENABLED="false" \
        LANG=zh_CN.UTF-8 \
        JAVA_OPT_EXT="--server.tomcat.basedir=/home/nacos/logs"

WORKDIR /$BASE_DIR

COPY --from=standard $BASE_DIR/bin/ bin/
COPY --from=standard $BASE_DIR/conf/ conf/
COPY --from=standard $BASE_DIR/init.d/ init.d/
COPY --from=standard $BASE_DIR/logs/ logs/
COPY --from=build /tmp/nacos-${NACOS_VERSION}/distribution/target/nacos-server-${NACOS_VERSION}/nacos/target/nacos-server.jar target/

RUN  apk add --no-cache bash libstdc++ dos2unix \
	&& dos2unix bin/docker-startup.sh conf/* \
	&& chmod +x bin/docker-startup.sh \
	&& apk del dos2unix \
	&& touch logs/start.out \
	&& ln -sf /dev/stdout logs/start.out \
	&& ln -sf /dev/stderr logs/start.out

EXPOSE 8848
ENTRYPOINT ["bash", "bin/docker-startup.sh"]
