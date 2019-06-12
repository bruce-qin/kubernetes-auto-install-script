#!/bin/bash
KUBERNETES_HOME=/usr/local/kubernetes
#kubernetes配置文件
if [ ! -f "$KUBERNETES_HOME/cfg//token.csv" ]; then
    echo "证书文件不存在，请先生成证书"
    exit 1
fi
token0=$(cat $KUBERNETES_HOME/cfg//token.csv)
kube_bootstrap_token=${token0%%,*}
read -p "set kube-apiserver connect addtess(设置kube-apiserver通信地址)[like http://127.0.0.1:8080/ or https://10.2.8.44:6443]:" MASTER_CONNECTION_ADDRESS
echo "kube-apiserver connect addtess:[${MASTER_CONNECTION_ADDRESS:?'kube-apiserver通信地址不能为空'}]"

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
rm -f $KUBERNETES_HOME/ssl/kubelet*
rm -f $KUBERNETES_HOME/cfg/kubelet-ssl.kubeconfig
systemctl restart kube-proxy kubelet
