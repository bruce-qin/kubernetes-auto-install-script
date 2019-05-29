#/bin/bash

SHELLDIR=$(cd $(dirname $0); pwd)

#关闭selinux
sed -i 's/^SELINUX=\(\(enforcing\)\|\(permissive\)\)$/SELINUX=disabled/g' /etc/selinux/config

#系统配置修改
#$1:'config key prefix'; $2:'new config'; $3:'file path';
replace_or_append_file_config(){
	key_prefix=$1
	key_prefix_convert=${key_prefix//\//\\\/}
	new_config=$2
	new_config_convert=${new_config//\//\\\/}
	file_path=$3
	if [ ! -f "$file_path" ]; then
		touch $file_path
	fi
	config_line=`sed -n -e "/$key_prefix_convert/=" $file_path`
	if [ $? -eq 0 -a "$config_line" != "" ]; then
		sed -i "s/^${key_prefix_convert}.*/$new_config_convert/g" $file_path
	else
		echo "$new_config" >>$file_path
	fi
}

#设置内核参数
config_sysctl_conf(){
replace_or_append_file_config fs.file-max fs.file-max=52706963 /etc/sysctl.conf
replace_or_append_file_config fs.nr_open fs.nr_open=52706963 /etc/sysctl.conf
replace_or_append_file_config fs.inotify.max_user_watches fs.inotify.max_user_watches=89100 /etc/sysctl.conf
replace_or_append_file_config vm.swappiness vm.swappiness=0 /etc/sysctl.conf
replace_or_append_file_config vm.overcommit_memory vm.overcommit_memory=1 /etc/sysctl.conf
replace_or_append_file_config vm.panic_on_oom vm.panic_on_oom=0 /etc/sysctl.conf
replace_or_append_file_config net.bridge.bridge-nf-call-ip6tables net.bridge.bridge-nf-call-ip6tables=1 /etc/sysctl.conf
replace_or_append_file_config net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-iptables=1 /etc/sysctl.conf
replace_or_append_file_config net.core.netdev_max_backlog net.core.netdev_max_backlog=32768 /etc/sysctl.conf
replace_or_append_file_config net.core.somaxconn net.core.somaxconn=32768 /etc/sysctl.conf
replace_or_append_file_config net.core.wmem_default net.core.wmem_default=8388608 /etc/sysctl.conf
replace_or_append_file_config net.core.rmem_default net.core.rmem_default=8388608 /etc/sysctl.conf
replace_or_append_file_config net.core.rmem_max net.core.rmem_max=16777216 /etc/sysctl.conf
replace_or_append_file_config net.core.wmem_max net.core.wmem_max=16777216 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.ip_forward net.ipv4.ip_forward=1 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_tw_recycle net.ipv4.tcp_tw_recycle=0 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_max_tw_buckets net.ipv4.tcp_max_tw_buckets=6000 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_sack net.ipv4.tcp_sack=1 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_window_scaling net.ipv4.tcp_window_scaling=1 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_rmem 'net.ipv4.tcp_rmem=4096 87380 4194304' /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_wmem 'net.ipv4.tcp_wmem=4096 16384 4194304' /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_max_syn_backlog net.ipv4.tcp_max_syn_backlog=16384 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_timestamps net.ipv4.tcp_timestamps=1 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_fin_timeout net.ipv4.tcp_fin_timeout=20 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_synack_retries net.ipv4.tcp_synack_retries=2 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_syn_retries net.ipv4.tcp_syn_retries=2 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_syncookies net.ipv4.tcp_syncookies=1 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_tw_reuse net.ipv4.tcp_tw_reuse=1 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_mem 'net.ipv4.tcp_mem=94500000 915000000 927000000' /etc/sysctl.conf
replace_or_append_file_config net.ipv4.tcp_max_orphans net.ipv4.tcp_max_orphans=3276800 /etc/sysctl.conf
replace_or_append_file_config net.ipv4.ip_local_port_range 'net.ipv4.ip_local_port_range=1024 65000' /etc/sysctl.conf
replace_or_append_file_config net.ipv6.conf.all.disable_ipv6 net.ipv6.conf.all.disable_ipv6=1 /etc/sysctl.conf
replace_or_append_file_config net.nf_conntrack_max net.nf_conntrack_max=6553500 /etc/sysctl.conf
replace_or_append_file_config net.netfilter.nf_conntrack_tcp_timeout_close_wait net.netfilter.nf_conntrack_tcp_timeout_close_wait=60 /etc/sysctl.conf
replace_or_append_file_config net.netfilter.nf_conntrack_tcp_timeout_fin_wait net.netfilter.nf_conntrack_tcp_timeout_fin_wait=120 /etc/sysctl.conf
replace_or_append_file_config net.netfilter.nf_conntrack_tcp_timeout_time_wait net.netfilter.nf_conntrack_tcp_timeout_time_wait=120 /etc/sysctl.conf
replace_or_append_file_config net.netfilter.nf_conntrack_tcp_timeout_established net.netfilter.nf_conntrack_tcp_timeout_established=3600 /etc/sysctl.conf
}
config_sysctl_conf
modprobe br_netfilter
sysctl -p 

ipvs_file=/etc/sysconfig/modules/ipvs.modules
if [ ! -f "$ipvs_file" ]; then
	cat > $ipvs_file <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
	chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4 
fi

#创建目录
KUBERNETES_HOME=/usr/local/kubernetes
mkdir -p $KUBERNETES_HOME/{bin,cfg,logs,ssl/etcd}
unzip -o $SHELLDIR/kubernetes-master.zip -d $SHELLDIR/
chmod +x $SHELLDIR/kube-* $SHELLDIR/kubectl
read -p "set kube-apiserver bind ip(设置kube-apiserver绑定ip)[default 127.0.0.1]:" MASTER_ADDRESS
echo "kube-apiserver bind ip:[${MASTER_ADDRESS:=127.0.0.1}]"
read -p "set kube-apiserver communication bind port(设置kube-apiserver加密通讯绑定端口)[default 6443]:" MASTER_BIND_PORT
echo "kube-apiserver communication bind port:[${MASTER_BIND_PORT:=6443}]"
read -p "set kubelet cluster ip range(设置kubelet集群服务容器ip地址范围)[default 172.17.0.0/16]" SERVICE_CLUSTER_IP_RANGE
echo "kubelet cluster ip range:[${SERVICE_CLUSTER_IP_RANGE:=172.17.0.0/16}]"
#安装kube-apiserver
install_kube_apiserver(){
    read -p "set kube-apiserver etcd connection address(设置kube-apiserver etcd通讯地址,多个用英文逗号分隔)[default https://127.0.0.1:2379]:" ETCD_SERVERS
    echo "kube-apiserver etcd connection address:[${ETCD_SERVERS:=https://127.0.0.1:2379}]"
    
    \cp -rf $SHELLDIR/kube-apiserver $KUBERNETES_HOME/bin
    chmod +x $KUBERNETES_HOME/bin/kube-apiserver
    cat >$KUBERNETES_HOME/cfg/kube-apiserver <<EOF
# --logtostderr=true: log to standard error instead of files
KUBE_LOGTOSTDERR="--logtostderr=true"
# --v=0: log level for V logs
KUBE_LOG_LEVEL="--v=4"
# --etcd-servers=[]: List of etcd servers to watch (http://ip:port),
# comma separated. Mutually exclusive with -etcd-config
KUBE_ETCD_SERVERS="--etcd-servers=${ETCD_SERVERS}"
# --etcd-cafile="": SSL Certificate Authority file used to secure etcd communication.
KUBE_ETCD_CAFILE="--etcd-cafile=$KUBERNETES_HOME/ssl/etcd/ca-etcd.pem"
# --etcd-certfile="": SSL certification file used to secure etcd communication.
KUBE_ETCD_CERTFILE="--etcd-certfile=$KUBERNETES_HOME/ssl/etcd/server-etcd.pem"
# --etcd-keyfile="": key file used to secure etcd communication.
KUBE_ETCD_KEYFILE="--etcd-keyfile=$KUBERNETES_HOME/ssl/etcd/server-etcd-key.pem"
# --insecure-bind-address=127.0.0.1: The IP address on which to serve the --insecure-port.
KUBE_API_ADDRESS="--insecure-bind-address=127.0.0.1"
KUBE_API_ADDRESS2="--bind-address=${MASTER_ADDRESS}"
# --insecure-port=8080: The port on which to serve unsecured, unauthenticated access.
KUBE_API_PORT="--insecure-port=8080"
KUBE_API_PORT2="--secure-port=$MASTER_BIND_PORT"
# --kubelet-port=10250: Kubelet port
NODE_PORT="--kubelet-port=10250"
# --advertise-address=<nil>: The IP address on which to advertise
# the apiserver to members of the cluster.
KUBE_ADVERTISE_ADDR="--advertise-address=${MASTER_ADDRESS}"
# --allow-privileged=false: If true, allow privileged containers.
KUBE_ALLOW_PRIV="--allow-privileged=true"
# --service-cluster-ip-range=<nil>: A CIDR notation IP range from which to assign service cluster IPs.
# This must not overlap with any IP ranges assigned to nodes for pods.
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"
# --admission-control="AlwaysAdmit": Ordered list of plug-ins
# to do admission control of resources into cluster.
# Comma-delimited list of:
#   LimitRanger, AlwaysDeny, SecurityContextDeny, NamespaceExists,
#   NamespaceLifecycle, NamespaceAutoProvision, AlwaysAdmit,
#   ServiceAccount, DefaultStorageClass, DefaultTolerationSeconds, ResourceQuota
# Mark Deprecated. Use --enable-admission-plugins or --disable-admission-plugins instead since v1.10.
# It will be removed in a future version.
KUBE_ADMISSION_CONTROL="--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction"
# --client-ca-file="": If set, any request presenting a client certificate signed
# by one of the authorities in the client-ca-file is authenticated with an identity
# corresponding to the CommonName of the client certificate.
KUBE_API_CLIENT_CA_FILE="--client-ca-file=$KUBERNETES_HOME/ssl/ca-k8s.pem"
KUBE_API_SERVER_ACCOUNT_KEY_FILE="--service-account-key-file=$KUBERNETES_HOME/ssl/ca-k8s-key.pem"
# --tls-cert-file="": File containing x509 Certificate for HTTPS.  (CA cert, if any,
# concatenated after server cert). If HTTPS serving is enabled, and --tls-cert-file
# and --tls-private-key-file are not provided, a self-signed certificate and key are
# generated for the public address and saved to /var/run/kubernetes.
KUBE_API_TLS_CERT_FILE="--tls-cert-file=$KUBERNETES_HOME/ssl/server-k8s.pem"
# --tls-private-key-file="": File containing x509 private key matching --tls-cert-file.
KUBE_API_TLS_PRIVATE_KEY_FILE="--tls-private-key-file=$KUBERNETES_HOME/ssl/server-k8s-key.pem"
KUBE_AUTH_INFO="--authorization-mode=RBAC,Node"
KUBE_BOOTSTRAP_TOKEN_AUTH="--enable-bootstrap-token-auth"
KUBE_TOKEN_AUTH_FILE="--token-auth-file=$KUBERNETES_HOME/cfg/token.csv"
EOF

    KUBE_APISERVER_OPTS="   \${KUBE_LOGTOSTDERR}                \\
                            \${KUBE_LOG_LEVEL}                  \\
                            \${KUBE_ETCD_SERVERS}               \\
                            \${KUBE_ETCD_CAFILE}                \\
                            \${KUBE_ETCD_CERTFILE}              \\
                            \${KUBE_ETCD_KEYFILE}               \\
                            \${KUBE_API_ADDRESS}                \\
                            \${KUBE_API_ADDRESS2}               \\
                            \${KUBE_API_PORT}                   \\
                            \${KUBE_API_PORT2}                  \\
                            \${NODE_PORT}                       \\
                            \${KUBE_ADVERTISE_ADDR}             \\
                            \${KUBE_ALLOW_PRIV}                 \\
                            \${KUBE_SERVICE_ADDRESSES}          \\
                            \${KUBE_ADMISSION_CONTROL}          \\
                            \${KUBE_AUTH_INFO}                  \\
                            \${KUBE_BOOTSTRAP_TOKEN_AUTH}       \\
                            \${KUBE_TOKEN_AUTH_FILE}            \\
                            \${KUBE_API_CLIENT_CA_FILE}         \\
                            \${KUBE_API_TLS_CERT_FILE}          \\
                            \${KUBE_API_SERVER_ACCOUNT_KEY_FILE}\\
                            \${KUBE_API_TLS_PRIVATE_KEY_FILE}"


    cat >/usr/lib/systemd/system/kube-apiserver.service <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=-$KUBERNETES_HOME/cfg/kube-apiserver
ExecStart=$KUBERNETES_HOME/bin/kube-apiserver ${KUBE_APISERVER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable kube-apiserver
    systemctl restart kube-apiserver
}


#安装kube-controller-manager
install_kube_controller_manager(){
    \cp -rf $SHELLDIR/kube-controller-manager $KUBERNETES_HOME/bin
    chmod +x $KUBERNETES_HOME/bin/kube-controller-manager
    cat >$KUBERNETES_HOME/cfg/kube-controller-manager <<EOF
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=4"
KUBE_MASTER="--master=127.0.0.1:8080"
# --service-cluster-ip-range=<nil>: A CIDR notation IP range from which to assign service cluster IPs.
# This must not overlap with any IP ranges assigned to nodes for pods.
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"
# --root-ca-file="": If set, this root certificate authority will be included in
# service account's token secret. This must be a valid PEM-encoded CA bundle.
KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE="--root-ca-file=$KUBERNETES_HOME/ssl/ca-k8s.pem"
# --service-account-private-key-file="": Filename containing a PEM-encoded private
# RSA key used to sign service account tokens.
KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE="--service-account-private-key-file=$KUBERNETES_HOME/ssl/ca-k8s-key.pem"
# --leader-elect: Start a leader election client and gain leadership before
# executing the main loop. Enable this when running replicated components for high availability.
KUBE_LEADER_ELECT="--leader-elect"
KUBE_CLUSTER_NAME="--cluster-name=kubernetes"
KUBE_CLUSTER_SIGNING_CERT_FILE="--cluster-signing-cert-file=$KUBERNETES_HOME/ssl/ca-k8s.pem"
KUBE_CLUSTER_SIGNING_KEY_FILE="--cluster-signing-key-file=$KUBERNETES_HOME/ssl/ca-k8s-key.pem"
EOF

    KUBE_CONTROLLER_MANAGER_OPTS="  \${KUBE_LOGTOSTDERR}        \\
                                    \${KUBE_LOG_LEVEL}          \\
                                    \${KUBE_MASTER}             \\
                                    \${KUBE_SERVICE_ADDRESSES}  \\
                                    \${KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE} \\
                                    \${KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE}\\
                                    \${KUBE_CLUSTER_NAME}       \\
                                    \${KUBE_CLUSTER_SIGNING_CERT_FILE}  \\
                                    \${KUBE_CLUSTER_SIGNING_KEY_FILE}   \\
                                    \${KUBE_LEADER_ELECT}"

    cat >/usr/lib/systemd/system/kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target
After=network-online.target kube-apiserver.service
Wants=network-online.target kube-apiserver.service

[Service]
EnvironmentFile=-$KUBERNETES_HOME/cfg/kube-controller-manager
ExecStart=$KUBERNETES_HOME/bin/kube-controller-manager ${KUBE_CONTROLLER_MANAGER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable kube-controller-manager
    systemctl restart kube-controller-manager
}

#安装kube-scheduler
install_kube_scheduler(){
    \cp -rf $SHELLDIR/kube-scheduler $KUBERNETES_HOME/bin
    chmod +x $KUBERNETES_HOME/bin/kube-scheduler
    cat >$KUBERNETES_HOME/cfg/kube-scheduler <<EOF
###
# kubernetes scheduler config
# --logtostderr=true: log to standard error instead of files
KUBE_LOGTOSTDERR="--logtostderr=true"
# --v=0: log level for V logs
KUBE_LOG_LEVEL="--v=4"
# --master: The address of the Kubernetes API server (overrides any value in kubeconfig).
KUBE_MASTER="--master=127.0.0.1:8080"
# --leader-elect: Start a leader election client and gain leadership before
# executing the main loop. Enable this when running replicated components for high availability.
KUBE_LEADER_ELECT="--leader-elect"
# Add your own!
KUBE_SCHEDULER_ARGS=""
EOF

    KUBE_SCHEDULER_OPTS="   \${KUBE_LOGTOSTDERR}     \\
                            \${KUBE_LOG_LEVEL}       \\
                            \${KUBE_MASTER}          \\
                            \${KUBE_LEADER_ELECT}    \\
                            \$KUBE_SCHEDULER_ARGS"

    cat >/usr/lib/systemd/system/kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=network.target
After=network-online.target kube-apiserver.service
Wants=network-online.target kube-apiserver.service

[Service]
EnvironmentFile=-$KUBERNETES_HOME/cfg/kube-scheduler
ExecStart=$KUBERNETES_HOME/bin/kube-scheduler ${KUBE_SCHEDULER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable kube-scheduler
    systemctl restart kube-scheduler
}

install_kube_apiserver
install_kube_controller_manager
install_kube_scheduler
\cp -rf $SHELLDIR/kubectl $KUBERNETES_HOME/bin
chmod +x $KUBERNETES_HOME/bin/kubectl

$KUBERNETES_HOME/bin/kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap