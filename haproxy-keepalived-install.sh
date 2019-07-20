#!/bin/bash
SHELLDIR=$(cd $(dirname $0); pwd)
yum install gcc gcc-c++ pcre-devel zlib-devel libnl3-devel ipset-devel iptables-devel libnfnetlink-devel popt popt-static popt-devel kernel-headers kernel-devel make net-snmp-devel  wget openssl-devel -y

#install haproxy
haproxy_install(){
cd $SHELLDIR
HAPROXY_INSTALL_DIR=/usr/local/haproxy
read -p "kube-apiserver proxy listen port(输入kube-apiserver，代理监听默认端口，如果haproxy与kube-apiserver安装在一台机器，注意端口冲突)[default 6443]:" KUBE_APISERVER_PROXY_LISTEN_PORT
echo "kube-apiserver proxy listen port [${KUBE_APISERVER_PROXY_LISTEN_PORT:=6443}]"
read -p "set kube-apiserver proxy server ip ports(输入代理kube-apiserver服务ip端口)[example:  172.17.100.11:6443,172.17.100.12:6443]:" KUBE_APISERVER_PROXY_SERVERS
echo "kube-apiserver proxy servers:[${KUBE_APISERVER_PROXY_SERVERS?'kube-apiser 服务地址不能为空'}]"
if [ ! -f "$SHELLDIR/haproxy.tar.gz" ]; then
    wget -O $SHELLDIR/haproxy.tar.gz https://github.com/haproxy/haproxy/archive/v2.0.0.tar.gz
fi
tar -xzf $SHELLDIR/haproxy.tar.gz
cd $(ls -F | grep haproxy.*/)
make TARGET=linux-glibc PREFIX=$HAPROXY_INSTALL_DIR
make install PREFIX=$HAPROXY_INSTALL_DIR
groupadd haproxy
useradd -g haproxy haproxy -s /sbin/nologin
cat >$HAPROXY_INSTALL_DIR/kubernetes-apiserver.cfg <<EOF
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
	log 127.0.0.1 local0 warning
	chroot $HAPROXY_INSTALL_DIR
	pidfile /var/run/haproxy.pid
	maxconn 4000
	user haproxy
	group haproxy
	daemon
	stats socket $HAPROXY_INSTALL_DIR/stats
defaults
	mode tcp
	log global
	option tcplog
	option dontlognull
	retries 3
	timeout http-request 10s
	timeout queue 1m
	timeout connect 10s
	timeout client 1m
	timeout server 1m
	timeout http-keep-alive 10s
	timeout check 10s
	maxconn 600
listen stats
	mode http
	bind 0.0.0.0:8082
	stats enable
	stats hide-version
	stats uri /stats
	stats realm Haproxy\ Statistics
	stats auth admin:admin
	stats admin if TRUE
frontend k8s-apiserver-frontend
	bind 0.0.0.0:${KUBE_APISERVER_PROXY_LISTEN_PORT}
	mode tcp
	log global
	default_backend k8s-apiserver-backend
backend k8s-apiserver-backend
	#balance leastconn
	#定义负载均衡方式为roundrobin方式, 即基于权重进行轮询调度的算法, 在服务器性能分布较均匀情况下推荐.
	balance roundrobin
	mode tcp
	#基于源地址实现持久连接.
	stick-table type ip size 200k expire 30m
	stick on src
	#后端服务器定义, maxconn 1024表示该服务器的最大连接数, cookie 1表示serverid为1, weight代表权重(默认1，最大为265，0则表示不参与负载均衡),
	#check inter 1500是检测心跳频率, rise 2是2次正确认为服务器可用, fall 3是3次失败认为服务器不可用.
EOF
apiserver_array=(${KUBE_APISERVER_PROXY_SERVERS//,/ })
for((i=0;i<=$((${#apiserver_array[*]}-1));i++));
do
echo "	server kubenode$i ${apiserver_array[i]} maxconn 1024 weight 3 check inter 1500 rise 2 fall 3" >>$HAPROXY_INSTALL_DIR/kubernetes-apiserver.cfg
done
cat > /etc/init.d/haproxy <<EOF
#!/bin/sh
#chkconfig: 2345 99 99
#description: haproxy

HAPROXY_HOME=$HAPROXY_INSTALL_DIR
CONFIG_FILE=\$HAPROXY_HOME/kubernetes-apiserver.cfg
case \$1 in
start)
    \$HAPROXY_HOME/sbin/haproxy -f \$CONFIG_FILE
    echo "start haproxy over"
    ;;
stop)
    flag=0
    count=0
    while  [ \$flag -lt 1 ]; do
        flag=1
        haproxy_pid=`ps -ef|grep \$HAPROXY_HOME/sbin/haproxy | grep -v grep | awk '{print \$2}'`
        echo "haproxy pid [\$haproxy_pid] is stoping..."
        if [ "\$haproxy_pid" != "" ]
            then
            sleep 1s
            echo "sleep \$((count++)) seconds"
            flag=0
            if [ \$count -gt 10 ]
                then
                flag=1
                kill -9 \$haproxy_pid
            fi
        else
            flag=1
        fi
    done
    echo "stop haproxy over"
    ;;
restart)
    \$0 stop
    \$0 start
    ;;
*)
    echo "usage haproxy [start|stop|restart]"
    ;;
esac
EOF
chmod +x /etc/init.d/haproxy
chkconfig --add  /etc/init.d/haproxy
chkconfig haproxy on
service haproxy restart
}

haproxy_install

#install keepalived
keepalived_install(){
cd $SHELLDIR
KEEPALIVED_HOME=/usr/local/keepalived
if [ ! -f "$SHELLDIR/keepalived.tar.gz" ]; then
    wget -O $SHELLDIR/keepalived.tar.gz https://github.com/haproxy/haproxy/archive/v2.0.0.tar.gz
fi
read -p "set keepalived bind interface name(设置keepalived绑定物理网卡名称)[example:  eth0]:" KEEPALIVED_BIND_INTERFACE
echo "keepalived bind interface name:[${KEEPALIVED_BIND_INTERFACE?'keepalived绑定物理网卡不能为空'}]"
read -p "set keepalived bind virtual ipaddress(设置keepalived绑定虚拟ip地址)[example:  192.168.100.100]:" KEEPALIVED_VIRTUAL_IPADDRESS
echo "keepalived bind virtual ipaddress:[${KEEPALIVED_VIRTUAL_IPADDRESS?'keepalived绑定虚拟ip地址不能为空'}]"
tar -xzf $SHELLDIR/keepalived.tar.gz
cd $(ls -F | grep keepalived.*/)
./build_setup
./configure --prefix=$KEEPALIVED_HOME
make && make install
#ln -s $KEEPALIVED_HOME/etc/sysconfig/keepalived /etc/sysconfig/
#ln -s $KEEPALIVED_HOME/sbin/keepalived /usr/sbin/
#mkdir -p /etc/keepalived
#ln -s  $KEEPALIVED_HOME/etc/keepalived/keepalived.conf /etc/keepalived/
#cp ./keepalived/etc/init.d/keepalived /etc/init.d/
#chkconfig --add keepalived
#chkconfig keepalived on
systemctl enable keepalived
cp $KEEPALIVED_HOME/etc/keepalived/keepalived.conf  $KEEPALIVED_HOME/etc/keepalived/keepalived.conf.bak
cat >$KEEPALIVED_HOME/etc/keepalived/check_haproxy.sh <<EOF
#!/bin/bash
if [ \$(ps -C haproxy --no-header | wc -l) -eq 0 ]; then
exit 1
else
exit 0
fi
EOF
chmod +x $KEEPALIVED_HOME/etc/keepalived/check_haproxy.sh
cat >$KEEPALIVED_HOME/etc/keepalived/keepalived.conf <<EOF
#=====================================================
# keepalived.conf 配置
#------------------------------------------------------------
# 1、Keepalived 配置文件以block形式组织，每个块内容都包含在{}
# 2、“#”,“!”开头行为注释
# 3、keepalived 配置为三类：
#    (1)全局配置:对整个keepalived都生效的配置
#    (2)VRRPD 配置:核心配置，主要实现keepalived高可用功能
#    (3)LVS配置
#=====================================================

! Configuration File for keepalived

########################
#  全局配置
########################
# global_defs 全局配置标识;
#global_defs {
#
## notification_email用于设置报警邮件地址; 可以设置多个,每行一个; 设置邮件报警需开启本机Sendmail服务
#   notification_email {
#     root@localhost.local
#   }
#
## 设置邮件发送地址, smtp server地址, 连接smtp sever超时时间
#   notification_email_from root@localhost.local
#   smtp_server 10.11.4.151
#   smtp_connect_timeout 30
#
## 表示运行keepalived服务器标识，邮件发送时在主题中显示的信息
#   router_id Haproxy_DEVEL
#}

######################
#  服务检测配置
######################
# 服务探测，chk_haproxy为服务名返回0说明服务是正常的
vrrp_script chk_haproxy {
        script "$KEEPALIVED_HOME/etc/keepalived/check_haproxy.sh"

#每隔2秒探测一次
        interval 2

#haproxy不在线,权重减-20
   weight -20
}

######################
#  VRRPD配置
######################
# VRRPD配置标识，VI_1是实例名称
vrrp_instance VI_1 {

# 指定Keepalvied角色,MASTER(必须大写)表示此主机为主服务器,BACKUP则是表示为备用服务器;
# 这里因为配置非抢占模式,nopreempt只作用于BACKUP,将2台主机均配置为BACKUP
    state BACKUP

# 指定HA监测网络的接口
    interface $KEEPALIVED_BIND_INTERFACE

# 虚拟路由标识,标识为数字,1-255可选；
# 同1个VRRP实例使用唯一的标识,MASTER_ID = BACKUP_ID
    virtual_router_id 51

# 定义节点优先级,数字越大表示节点的优先级越高;
# 同1个VRRP_instance下，MASTE_PRIORITY > BACKUP_PRIORITY
    priority 100

# MASTER与BACKUP主机之间同步检查的时间间隔,单位为秒
    advert_int 1

# 从实际应用角度,建议配置非抢占模式,防止网络频繁切换震荡
    nopreempt


# 设定节点间通信验证类型与密码，验证类型主要有PASS和AH两种；
# 同1个vrrp_instance，MASTER验证密码和BACKUP保持一致
    authentication {
        auth_type PASS
        auth_pass 456789
    }

# 设置虚拟IP地址(VIP),又叫做漂移IP地址;
# 可设置多个，1行1个;
# keepalived通过“ip address add”命令的形式将VIP添加到系统
    virtual_ipaddress {
        $KEEPALIVED_VIRTUAL_IPADDRESS
    }

# 脚本追踪,对应服务检测
    track_script {
        chk_haproxy
    }
    notify_master "/etc/init.d/haproxy restart"
    notify_backup "/etc/init.d/haproxy stop"
}
EOF
ln -sf /usr/local/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
systemctl enable keepalived
systemctl restart keepalived
}
keepalived_install
