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
mkdir -p $KUBERNETES_HOME/{bin,cfg,logs,ssl}
unzip -o $SHELLDIR/kubernetes-node.zip -d $SHELLDIR/
chmod +x $SHELLDIR/kube-* $SHELLDIR/kubectl
#install flannel
install_flannel(){
if [ ! -f "$KUBERNETES_HOME/bin/flanneld" ];then
    if [ ! -f "$SHELLDIR/flanneld" ]; then
        wget https://github.com/coreos/flannel/releases/download/v0.11.0/flannel-v0.11.0-linux-amd64.tar.gz
        tar -xzf flannel-v0.11.0-linux-amd64.tar.gz
        rm -f flannel-v0.11.0-linux-amd64.tar.gz
        mv -f flanneld mk-docker-opts.sh $SHELLDIR/
    fi
    chmod +x $SHELLDIR/flanneld $SHELLDIR/mk-docker-opts.sh
    \cp -rf $SHELLDIR/flanneld $SHELLDIR/mk-docker-opts.sh $KUBERNETES_HOME/bin/
fi
    read -p "set etcd client endpoints(设置flannel的etcd存储url) [default https://127.0.0.1:2379]:" ETCD_ENDPOINTS
    echo "etcd client endpoints:[${ETCD_ENDPOINTS:=https://127.0.0.1:2379}]"
    echo "FLANNEL_OPTIONS=\"--etcd-endpoints=$ETCD_ENDPOINTS -etcd-cafile=$KUBERNETES_HOME/ssl/etcd/ca-etcd.pem -etcd-certfile=$KUBERNETES_HOME/ssl/etcd/server-etcd.pem -etcd-keyfile=$KUBERNETES_HOME/ssl/etcd/server-etcd-key.pem -etcd-prefix=/k8s/network\"" >$KUBERNETES_HOME/cfg/flanneld
    cat >/usr/lib/systemd/system/flanneld.service <<EOF
[Unit]
Description=Flannel overlay address etcd agent
After=network-online.target network.target
Before=docker.service

[Service]
Type=notify
EnvironmentFile=$KUBERNETES_HOME/cfg/flanneld
ExecStart=$KUBERNETES_HOME/bin/flanneld --ip-masq \$FLANNEL_OPTIONS
ExecStartPost=$KUBERNETES_HOME/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure

[Install]
wantedBy=multi-user.target
EOF
}

#install docker
install_docker(){
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["http://f1361db2.m.daocloud.io", "http://hub-mirror.c.163.com"],
    "insecure-registries": [],
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
}
EOF
cat >/usr/lib/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service flanneld.service
Wants=network-online.target flanneld.service
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
EnvironmentFile=/run/flannel/subnet.env
ExecStart=/usr/bin/dockerd  -H fd:// --containerd=/run/containerd/containerd.sock \$DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
}

install_flannel
install_docker
systemctl daemon-reload
systemctl restart flanneld docker  
systemctl enable flanneld docker 

#kubernetes配置文件
if [ ! -f "$SHELLDIR/tls/token.csv" ]; then
    echo "证书文件不存在，请先生成证书"
    exit 1
fi
token0=$(cat $SHELLDIR/tls/token.csv)
kube_bootstrap_token=${token0%%,*}
read -p "set kube-apiserver connect addtess(设置kube-apiserver通信地址)[like http://127.0.0.1:8080/ or https://10.2.8.44:6443]:" MASTER_CONNECTION_ADDRESS
echo "kube-apiserver connect addtess:[${MASTER_CONNECTION_ADDRESS:?'kube-apiserver通信地址不能为空'}]"
read -p "set kubelet bind ip(设置kubelet绑定ip):" NODE_ADDRESS
echo "kubelet bind ip:[${NODE_ADDRESS:?'kueblet 绑定地址不能为空'}]"
\cp -rf $SHELLDIR/kubectl $KUBERNETES_HOME/bin
chmod +x $KUBERNETES_HOME/bin/kubectl

#生成kubelet配置
generate_kubelet_config(){
    #启动配置
    #设置集群参数
    $KUBERNETES_HOME/bin/kubectl config set-cluster kubernetes \
      --certificate-authority=$KUBERNETES_HOME/ssl/ca-k8s.pem \
      --embed-certs=true \
      --server=${MASTER_CONNECTION_ADDRESS} \
      --kubeconfig=$KUBERNETES_HOME/cfg/bootstrap.kubeconfig
     
    #设置客户端认证参数
    $KUBERNETES_HOME/bin/kubectl config set-credentials kubelet-bootstrap \
      --token=${kube_bootstrap_token} \
      --kubeconfig=$KUBERNETES_HOME/cfg/bootstrap.kubeconfig
     
    # 设置上下文参数
    $KUBERNETES_HOME/bin/kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=$KUBERNETES_HOME/cfg/bootstrap.kubeconfig
     
    # 设置默认上下文
    $KUBERNETES_HOME/bin/kubectl config use-context default --kubeconfig=$KUBERNETES_HOME/cfg/bootstrap.kubeconfig
    
    cat >$KUBERNETES_HOME/cfg/kubelet.config.yaml<<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: $NODE_ADDRESS
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS: ["172.17.0.2"]
clusterDomain: cluster.local
failSwapOn: false
authentication:
  anonymous:
    enabled: true
EOF
}

#生成kube-proxy配置
generate_kube_proxy_config(){
    $KUBERNETES_HOME/bin/kubectl config set-cluster kubernetes \
      --certificate-authority=$KUBERNETES_HOME/ssl/ca-k8s.pem \
      --embed-certs=true \
      --server=${MASTER_CONNECTION_ADDRESS} \
      --kubeconfig=$KUBERNETES_HOME/cfg/kube-proxy.kubeconfig
     
    $KUBERNETES_HOME/bin/kubectl config set-credentials kube-proxy \
      --client-certificate=$KUBERNETES_HOME/ssl/kube-proxy.pem \
      --client-key=$KUBERNETES_HOME/ssl/kube-proxy-key.pem \
      --embed-certs=true \
      --kubeconfig=$KUBERNETES_HOME/cfg/kube-proxy.kubeconfig
     
    $KUBERNETES_HOME/bin/kubectl config set-context default \
      --cluster=kubernetes \
      --user=kube-proxy \
      --kubeconfig=$KUBERNETES_HOME/cfg/kube-proxy.kubeconfig
     
    $KUBERNETES_HOME/bin/kubectl config use-context default --kubeconfig=$KUBERNETES_HOME/cfg/kube-proxy.kubeconfig
}

#安装kubelet
install_kubelet(){
    generate_kubelet_config

    KUBECONFIG_DIR=$KUBERNETES_HOME/cfg
    \cp -rf $SHELLDIR/kubelet $KUBERNETES_HOME/bin
    chmod +x $KUBERNETES_HOME/bin/kubelet

    cat  >$KUBERNETES_HOME/cfg/kubelet <<EOF
# --logtostderr=true: log to standard error instead of files
KUBE_LOGTOSTDERR="--logtostderr=true"
#  --v=0: log level for V logs
KUBE_LOG_LEVEL="--v=4"
# --hostname-override="": If non-empty, will use this string as identification instead of the actual hostname.
NODE_HOSTNAME="--hostname-override=${NODE_ADDRESS}"
# Path to a kubeconfig file, specifying how to connect to the API server.
KUBELET_KUBECONFIG="--kubeconfig=${KUBECONFIG_DIR}/kubelet-ssl.kubeconfig"
KUBELET_KUBECONFIG2="--config=${KUBECONFIG_DIR}/kubelet.config.yaml"
KUBELET_BOOTSTRAP_CONFIG="--bootstrap-kubeconfig=${KUBECONFIG_DIR}/bootstrap.kubeconfig"
CERT_DIR="--cert-dir=$KUBERNETES_HOME/ssl"
# Add your own!
KUBELET_ARGS="--pod-infra-container-image=mirrorgooglecontainers/pause-amd64:3.1 --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice"
EOF

    KUBELET_OPTS="      \${KUBE_LOGTOSTDERR}     \\
                        \${KUBE_LOG_LEVEL}       \\
                        \${NODE_HOSTNAME}        \\
                        \${KUBELET_KUBECONFIG}   \\
                        \${KUBELET_KUBECONFIG2}  \\
                        \${KUBELET_BOOTSTRAP_CONFIG}   \\
                        \${CERT_DIR}             \\
                        \$KUBELET_ARGS"

    cat >/usr/lib/systemd/system/kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=-$KUBERNETES_HOME/cfg/kubelet
ExecStart=$KUBERNETES_HOME/bin/kubelet ${KUBELET_OPTS}
Restart=on-failure
KillMode=process
RestartSec=15s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable kubelet
    systemctl restart kubelet
}


#安装kube-proxy
install_kube_proxy(){
    generate_kube_proxy_config
    read -p "set kubelet cluster ip range(设置kubelet集群服务pods ip地址范围,不能与api-server ip范围有重叠)[default 172.17.0.0/16]" SERVICE_CLUSTER_IP_RANGE
    echo "kubelet cluster ip range:[${SERVICE_CLUSTER_IP_RANGE:=172.17.0.0/16}]"
    \cp -rf $SHELLDIR/kube-proxy $KUBERNETES_HOME/bin
    chmod +x $KUBERNETES_HOME/bin/kube-proxy
    cat >$KUBERNETES_HOME/cfg/kube-proxy <<EOF
# --logtostderr=true: log to standard error instead of files
KUBE_LOGTOSTDERR="--logtostderr=true"
#  --v=0: log level for V logs
KUBE_LOG_LEVEL="--v=4"
# --hostname-override="": If non-empty, will use this string as identification instead of the actual hostname.
NODE_HOSTNAME="--hostname-override=${NODE_ADDRESS}"
# --master="": The address of the Kubernetes API server (overrides any value in kubeconfig)
KUBECONFIG_FILE="--kubeconfig=$KUBERNETES_HOME/cfg/kube-proxy.kubeconfig"
CLUSTER_CIDR="--cluster-cidr=$SERVICE_CLUSTER_IP_RANGE"
EOF

    KUBE_PROXY_OPTS="   \${KUBE_LOGTOSTDERR} \\
                        \${KUBE_LOG_LEVEL}   \\
                        \${NODE_HOSTNAME}    \\
                        \${CLUSTER_CIDR}    \\
                        \${KUBECONFIG_FILE}"

    cat >/usr/lib/systemd/system/kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-$KUBERNETES_HOME/cfg/kube-proxy
ExecStart=$KUBERNETES_HOME/bin/kube-proxy ${KUBE_PROXY_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable kube-proxy
    systemctl restart kube-proxy
}

install_kubelet
install_kube_proxy

#如果node kubelet启动失败：                                 cannot create certificate signing request: certificatesigningrequests.certificates.k8s.io is forbidden: User "system:anonymous" cannot create resource "certificatesigningrequests" in API group "certificates.k8s.io" at the cluster scope
#这里可能会有个报错导致启动失败：error: failed to run Kubelet: cannot create certificate signing request: certificatesigningrequests.certificates.k8s.io is forbidden: User "kubelet-bootstrap" cannot create certificatesigningrequests.certificates.k8s.io at the cluster scope
#原因是：kubelet-bootstrap并没有权限创建证书。所以要创建这个用户的权限并绑定到这个角色上。
#解决方法是在master上执行
#kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous
#kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
#查看csr
#kubectl get csr
#授权接入node
#kubectl certificate approve node-csr-ij3py9j-yi-eoa8sOHMDs7VeTQtMv0N3Efj3ByZLMdc
