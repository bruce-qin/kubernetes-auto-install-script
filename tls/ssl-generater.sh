#!/bin/bash

SHELLDIR=$(cd $(dirname $0); pwd)
chmod +x cfssl*
cp -n $SHELLDIR/cfssl_linux-amd64 /usr/local/bin/cfssl
cp -n $SHELLDIR/cfssljson_linux-amd64 /usr/local/bin/cfssljson
cp -n $SHELLDIR/cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo

#创建目录
KUBERNETES_HOME=/usr/local/kubernetes
mkdir -p $KUBERNETES_HOME/{bin,cfg,logs,ssl/etcd}

#hosts拼接函数
join_array(){
if [ "$1" != "" ]; then
    ip_array=(${1//,/ })
    result="\"${ip_array[0]}\""
    for((i=1;i<=$((${#ip_array[*]}-1));i++));
    do
    result="$result,\"${ip_array[i]}\""
    done
    echo $result
fi
}

#生成etcd证书
generate_etcd_ssl(){

mkdir -p $SHELLDIR/{ssl/etcd,config/etcd}
if [ "`ls -A $SHELLDIR/ssl/etcd`" = "" ];then
    cat >$SHELLDIR/config/etcd/ca-etcd-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "etcd": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF
    cat >$SHELLDIR/config/etcd/ca-etcd-csr.json << EOF
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "SiChuan",
            "ST": "ChengDu",
            "O": "developer",
            "OU": "java"
        }
    ]
}
EOF
read -p "set etcd server ips or hostnames (设置etcd集群授权访问主机IP地址或hostname,多个用英文逗号分割)[defalut 127.0.0.1]:" etcd_server_ip
echo "etcd servers ip or hostnames:[${etcd_server_ip:=127.0.0.1}]"
fixed_etcd_server_ip=`join_array $etcd_server_ip`
if [ "$fixed_etcd_server_ip" != "" ]; then
    fixed_etcd_server_ip=${fixed_etcd_server_ip}',"127.0.0.1","kubernetes","kubernetes.default","kubernetes.default.svc","kubernetes.default.svc.cluster","kubernetes.default.svc.cluster.local"'
else
    fixed_etcd_server_ip='"127.0.0.1","kubernetes","kubernetes.default","kubernetes.default.svc","kubernetes.default.svc.cluster","kubernetes.default.svc.cluster.local"'
fi
    cat >$SHELLDIR/config/etcd/server-etcd-csr.json << EOF
{
    "CN": "etcd",
    "hosts": [$fixed_etcd_server_ip],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "SiChuan",
            "ST": "ChengDu",
            "O": "developer",
            "OU": "java"
        }
    ]
}
EOF
    #生成etcd ca证书和私钥 初始化ca
    cfssl gencert -initca $SHELLDIR/config/etcd/ca-etcd-csr.json | cfssljson -bare $SHELLDIR/ssl/etcd/ca-etcd 
    #生成server证书
    cfssl gencert -ca=$SHELLDIR/ssl/etcd/ca-etcd.pem -ca-key=$SHELLDIR/ssl/etcd/ca-etcd-key.pem -config=$SHELLDIR/config/etcd/ca-etcd-config.json -profile=etcd $SHELLDIR/config/etcd/server-etcd-csr.json | cfssljson -bare $SHELLDIR/ssl/etcd/server-etcd
fi
\cp -rf $SHELLDIR/ssl/etcd/* $KUBERNETES_HOME/ssl/etcd/
}
generate_etcd_ssl

#生成kubenetes证书
generate_k8s_ssl(){

mkdir -p $SHELLDIR/{ssl/k8s,config/k8s}
if [ "`ls -A $SHELLDIR/ssl/k8s`" = "" ];then
cat >$SHELLDIR/config/k8s/ca-k8s-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF

cat >$SHELLDIR/config/k8s/ca-k8s-csr.json << EOF
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "SiChuan",
            "ST": "ChengDu",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
read -p "set k8s cluster ips or hostnames (设置k8s集群授权访问主机IP地址或hostname,多个用英文逗号分割)[defalut 127.0.0.1]:" k8s_server_ip
echo "k8s cluster ips or hostnames:[${k8s_server_ip:=127.0.0.1}]"
fixed_k8s_server_ip=`join_array $k8s_server_ip`
if [ "$fixed_k8s_server_ip" != "" ]; then
    fixed_k8s_server_ip=${fixed_k8s_server_ip}',"127.0.0.1","172.17.0.1","kubernetes","kubernetes.default","kubernetes.default.svc","kubernetes.default.svc.cluster","kubernetes.default.svc.cluster.local"'
else
    fixed_k8s_server_ip='"127.0.0.1","172.17.0.1","kubernetes","kubernetes.default","kubernetes.default.svc","kubernetes.default.svc.cluster","kubernetes.default.svc.cluster.local"'
fi
#apiserver证书
cat >$SHELLDIR/config/k8s/server-k8s-csr.json << EOF
{
    "CN": "kubernetes",
    "hosts": [$fixed_k8s_server_ip],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "SiChuan",
            "ST": "ChengDu",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF

#kube-proxy证书
cat >$SHELLDIR/config/k8s/kube-proxy-csr.json << EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
        "algo": "rsa",
        "size": 2048
  },
  "names": [
    {
        "C": "CN",
        "L": "SiChuan",
        "ST": "ChengDu",
        "O": "system:kube-proxy",
        "OU": "System"
    }
  ]
}
EOF

#kube-controller-manager证书
cat >$SHELLDIR/config/k8s/kube-controller-manager-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "hosts": [$fixed_k8s_server_ip],
  "key": {
        "algo": "rsa",
        "size": 2048
  },
  "names": [
    {
        "C": "CN",
        "L": "SiChuan",
        "ST": "ChengDu",
        "O": "system:kube-controller-manager",
        "OU": "System"
    }
  ]
}
EOF

#kube-scheduler证书
cat >$SHELLDIR/config/k8s/kube-scheduler-csr.json << EOF
{
  "CN": "system:kube-scheduler",
  "hosts": [$fixed_k8s_server_ip],
  "key": {
        "algo": "rsa",
        "size": 2048
  },
  "names": [
    {
        "C": "CN",
        "L": "SiChuan",
        "ST": "ChengDu",
        "O": "system:kube-scheduler",
        "OU": "System"
    }
  ]
}
EOF

#admin kubectl证书
cat >$SHELLDIR/config/k8s/admin-k8s-csr.json << EOF
{
  "CN": "admin",
  "hosts": [],
  "key": {
        "algo": "rsa",
        "size": 2048
  },
  "names": [
    {
        "C": "CN",
        "L": "SiChuan",
        "ST": "ChengDu",
        "O": "system:master",
        "OU": "System"
    }
  ]
}
EOF
cfssl gencert -initca $SHELLDIR/config/k8s/ca-k8s-csr.json | cfssljson -bare $SHELLDIR/ssl/k8s/ca-k8s
cfssl gencert -ca=$SHELLDIR/ssl/k8s/ca-k8s.pem -ca-key=$SHELLDIR/ssl/k8s/ca-k8s-key.pem -config=$SHELLDIR/config/k8s/ca-k8s-config.json -profile=kubernetes $SHELLDIR/config/k8s/server-k8s-csr.json | cfssljson -bare $SHELLDIR/ssl/k8s/server-k8s
cfssl gencert -ca=$SHELLDIR/ssl/k8s/ca-k8s.pem -ca-key=$SHELLDIR/ssl/k8s/ca-k8s-key.pem -config=$SHELLDIR/config/k8s/ca-k8s-config.json -profile=kubernetes $SHELLDIR/config/k8s/kube-proxy-csr.json | cfssljson -bare $SHELLDIR/ssl/k8s/kube-proxy
cfssl gencert -ca=$SHELLDIR/ssl/k8s/ca-k8s.pem -ca-key=$SHELLDIR/ssl/k8s/ca-k8s-key.pem -config=$SHELLDIR/config/k8s/ca-k8s-config.json -profile=kubernetes $SHELLDIR/config/k8s/kube-controller-manager-csr.json | cfssljson -bare $SHELLDIR/ssl/k8s/kube-controller-manager
cfssl gencert -ca=$SHELLDIR/ssl/k8s/ca-k8s.pem -ca-key=$SHELLDIR/ssl/k8s/ca-k8s-key.pem -config=$SHELLDIR/config/k8s/ca-k8s-config.json -profile=kubernetes $SHELLDIR/config/k8s/kube-scheduler-csr.json | cfssljson -bare $SHELLDIR/ssl/k8s/kube-scheduler
cfssl gencert -ca=$SHELLDIR/ssl/k8s/ca-k8s.pem -ca-key=$SHELLDIR/ssl/k8s/ca-k8s-key.pem -config=$SHELLDIR/config/k8s/ca-k8s-config.json -profile=kubernetes $SHELLDIR/config/k8s/admin-k8s-csr.json | cfssljson -bare $SHELLDIR/ssl/k8s/admin-k8s

fi
\cp -rf $SHELLDIR/ssl/k8s/* $KUBERNETES_HOME/ssl/
}
generate_k8s_ssl

generate_k8s_token(){
if [ ! -f "$SHELLDIR/token.csv" ];then
    token_uuid=`head -c 16 /dev/urandom | od -An -t x | tr -d ' '`
    echo "$token_uuid,kubelet-bootstrap,10001,\"system:kubelet-bootstrap\"" >$SHELLDIR/token.csv
fi
\cp -rf $SHELLDIR/token.csv $KUBERNETES_HOME/cfg/
}
generate_k8s_token

