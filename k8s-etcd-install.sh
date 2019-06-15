#/bin/bash

SHELLDIR=$(cd $(dirname $0); pwd)

read -p "set etcd bind ip:" bind_ip
echo ${bind_ip:?'etcd bind ip not set'}
read -p "set etcd alias name (设置etcd存储别名)[defalut etcd01]:" etcd_name
echo "etcd alias name:[${etcd_name:=etcd01}]"
etcd_data_dir="/var/lib/etcd/default.etcd"
#集群通讯地址
etcd_listen_peer_urls="https://$bind_ip:2380"
#客户端数据传输地址
etcd_listen_client_urls="https://$bind_ip:2379"
#集群节点urls因为逗号分割
read -p "set etcd initial cluster,(设置etcd集群通讯地址),like: etcd01=https://etcd01_bind_ip:peer_port,etcd02=https://etcd02_bind_ip:peer_port [defalut \"${etcd_name}=${etcd_listen_peer_urls}\"]:" etcd_initial_cluster
echo "etcd initial cluster:[${etcd_initial_cluster:=${etcd_name}=${etcd_listen_peer_urls}}]"


#关闭selinux
sed -i 's/^SELINUX=\(\(enforcing\)\|\(permissive\)\)$/SELINUX=disabled/g' /etc/selinux/config

#创建目录
KUBERNETES_HOME=/usr/local/kubernetes
mkdir -p $KUBERNETES_HOME/{bin,cfg,logs,ssl/etcd}

#install etcd
if [ ! -f $KUBERNETES_HOME/bin/etcd ]; then
    if [ ! -f "$SHELLDIR/etcd" ]; then
        wget https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz
        tar -xzf etcd-v3.3.13-linux-amd64.tar.gz 
        mv -f etcd-v3.3.13-linux-amd64/etcd etcd-v3.3.13-linux-amd64/etcdctl $SHELLDIR/
        rm -rf etcd-v3.3.13-linux-amd64
        rm -f etcd-v3.3.13-linux-amd64.tar.gz 
    fi
    chmod +x $SHELLDIR/etcd $SHELLDIR/etcdctl
    \cp -rf $SHELLDIR/etcd $SHELLDIR/etcdctl $KUBERNETES_HOME/bin/
fi
systemctl stop etcd
rm -rf $etcd_data_dir
cat > $KUBERNETES_HOME/cfg/etcd <<EOF
#[Member]
ETCD_NAME="$etcd_name"
ETCD_DATA_DIR="$etcd_data_dir"
#集群通讯地址
ETCD_LISTEN_PEER_URLS="$etcd_listen_peer_urls"
#客户端数据传输地址
ETCD_LISTEN_CLIENT_URLS="$etcd_listen_client_urls"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="$etcd_listen_peer_urls"
ETCD_ADVERTISE_CLIENT_URLS="$etcd_listen_client_urls"
#集群节点urls因为逗号分割
ETCD_INITIAL_CLUSTER="$etcd_initial_cluster"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"

#[Security]
ETCD_CERT_FILE="$KUBERNETES_HOME/ssl/etcd/server-etcd.pem"
ETCD_KEY_FILE="$KUBERNETES_HOME/ssl/etcd/server-etcd-key.pem"
ETCD_TRUSTED_CA_FILE="$KUBERNETES_HOME/ssl/etcd/ca-etcd.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_PEER_CERT_FILE="$KUBERNETES_HOME/ssl/etcd/server-etcd.pem"
ETCD_PEER_KEY_FILE="$KUBERNETES_HOME/ssl/etcd/server-etcd-key.pem"
ETCD_PEER_TRUSTED_CA_FILE="$KUBERNETES_HOME/ssl/etcd/ca-etcd.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"
EOF
ETCD_START_OPTIONS="--name=\${ETCD_NAME} \\
                    --data-dir=\${ETCD_DATA_DIR} \\
                    --listen-client-urls=\${ETCD_LISTEN_CLIENT_URLS} \\
                    --listen-peer-urls=\${ETCD_LISTEN_PEER_URLS} \\
                    --advertise-client-urls=\${ETCD_ADVERTISE_CLIENT_URLS} \\
                    --initial-cluster-token=\${ETCD_INITIAL_CLUSTER_TOKEN} \\
                    --initial-cluster=\${ETCD_INITIAL_CLUSTER} \\
                    --initial-cluster-state=\${ETCD_INITIAL_CLUSTER_STATE} \\
                    --cert-file=\${ETCD_CERT_FILE} \\
                    --key-file=\${ETCD_KEY_FILE} \\
                    --trusted-ca-file=\${ETCD_TRUSTED_CA_FILE} \\
                    --client-cert-auth=\${ETCD_CLIENT_CERT_AUTH} \\
                    --peer-cert-file=\${ETCD_PEER_CERT_FILE} \\
                    --peer-key-file=\${ETCD_PEER_KEY_FILE} \\
                    --peer-trusted-ca-file=\${ETCD_PEER_TRUSTED_CA_FILE} \\
                    --peer-client-cert-auth=\${ETCD_PEER_CLIENT_CERT_AUTH}"

cat > /usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=-$KUBERNETES_HOME/cfg/etcd
ExecStart=$KUBERNETES_HOME/bin/etcd $ETCD_START_OPTIONS
Restart=on-failure
LimitNOFILE=65535
RestartSec=15s
[Install]
wantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd

etcd_alias="alias etcdctl=\"$KUBERNETES_HOME/bin/etcdctl --ca-file=$KUBERNETES_HOME/ssl/etcd/ca-etcd.pem --cert-file=$KUBERNETES_HOME/ssl/etcd/server-etcd.pem --key-file=$KUBERNETES_HOME/ssl/etcd/server-etcd-key.pem\""
etcd_alias_convert=${etcd_alias//\//\\\/}
etcd_alias_line=`sed -n -e '/alias etcdctl/=' /etc/profile`
if [ $? -eq 0 -a "$etcd_alias_line" != "" ]; then
    sed -i "s/^alias etcdctl=.*/$etcd_alias_convert/g" /etc/profile
else
    echo $etcd_alias >>/etc/profile
fi
source /etc/profile

read -p "set kubelet cluster ip range(设置kubelet集群服务docker容器ip地址范围)[default 172.17.0.0/16]" SERVICE_CLUSTER_IP_RANGE
echo "kubelet cluster ip range:[${SERVICE_CLUSTER_IP_RANGE:=172.17.0.0/16}]"

etcdctl --endpoints="$etcd_listen_client_urls" \
set /k8s/network/config "{\"Network\": \"$SERVICE_CLUSTER_IP_RANGE\", \"Backend\": {\"Type\": \"vxlan\"}}"

sed -i 's/ETCD_INITIAL_CLUSTER_STATE="new"/ETCD_INITIAL_CLUSTER_STATE="existing"/' $KUBERNETES_HOME/cfg/etcd
systemctl restart etcd