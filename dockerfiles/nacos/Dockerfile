ARG NACOS_VERSION=1.2.1
ARG SPRING_BOOT_VERSION=2.2.7
ARG MYSQL_VERSION=8.0.20
ARG MINA_IO_VERSION=2.1.3
ARG MYSQL_OLD_CLASS=com.mysql.jdbc.jdbc2.optional.MysqlDataSource
ARG MYSQL_NEW_CLASS=com.mysql.cj.jdbc.MysqlDataSource

#阶段一 修改mysql数据库连接版本 并构建
FROM alpine AS build

RUN apk add --no-cache wget openjdk8 maven tar
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
ENV CLASSPATH=.:$JAVA_HOME/lib
ENV PATH=$PATH:$JAVA_HOME/bin

WORKDIR /tmp
RUN cd /tmp ;\
        wget https://github.com/alibaba/nacos/archive/1.2.1.tar.gz ;\
        tar -xzf 1.2.1.tar.gz

RUN sed -i "$(( $(sed -n -e '/spring-boot-dependencies/=' pom.xml) +1 ))s/<version>.*/<version>${SPRING_BOOT_VERSION}.RELEASE<\/version>/g" ./nacos-${NACOS_VERSION}/pom.xml
RUN sed -i "$(( $(sed -n -e '/mysql-connector-java/=' pom.xml) +1 ))s/<version>.*/<version>${MYSQL_VERSION}<\/version>/g" ./nacos-${NACOS_VERSION}/pom.xml
RUN sed -i "$(( $(sed -n -e '/mina-core/=' pom.xml) +1 ))s/<version>.*/<version>${MINA_IO_VERSION}<\/version>/g" ./nacos-${NACOS_VERSION}/pom.xml
RUN sed -i "s/${MYSQL_OLD_CLASS}/${MYSQL_NEW_CLASS}/g" ./nacos-${NACOS_VERSION}/naming/src/main/java/com/alibaba/nacos/naming/healthcheck/MysqlHealthCheckProcessor.java
RUN cd nacos-${NACOS_VERSION} && mvn -Prelease-nacos -Dmaven.test.skip=true clean install -U

#阶段二 拉取nacos官方镜像
FROM nacos/nacos-server:${NACOS_VERSION} AS standard

#阶段三 重新发布
FROM alpine AS release

RUN apk add --no-cache openjdk8-jre

ENV MODE="cluster" \
    PREFER_HOST_MODE="ip"\
    BASE_DIR="/home/nacos" \
    JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk" \
    CLASSPATH=".:/home/nacos/conf:$JAVA_HOME/lib" \
    CLUSTER_CONF="/home/nacos/conf/cluster.conf" \
    FUNCTION_MODE="all" \
    NACOS_USER="nacos" \
    JAVA="/usr/lib/jvm/java-1.8.0-openjdk/bin/java" \
    JVM_XMS="2g" \
    JVM_XMX="2g" \
    JVM_XMN="1g" \
    JVM_MS="128m" \
    JVM_MMS="320m" \
    NACOS_DEBUG="n" \
    TOMCAT_ACCESSLOG_ENABLED="false" \
    TIME_ZONE="Asia/Shanghai"

RUN mkdir -p $BASE_DIR

WORKDIR /$BASE_DIR

COPY --from=standard $BASE_DIR $BASE_DIR
COPY --from=build /tmp/nacos-${NACOS_VERSION}/distribution/target/nacos-server-${NACOS_VERSION}/nacos/target/nacos-server.jar $BASE_DIR/target/

RUN  cd logs \
	&& touch start.out \
	&& ln -sf /dev/stdout start.out \
	&& ln -sf /dev/stderr start.out
RUN chmod +x bin/docker-startup.sh

EXPOSE 8848
ENTRYPOINT ["bin/docker-startup.sh"]
