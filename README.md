# kubernetes集群二进制文件自签证书自动安装脚本

> master分支为最新的kubernetes版本，当前版本为1.14.2。当要使用其他k8s版本，如果配置文件兼容，只需要替换kubernetes二进制文件即可切换

> 主要脚本文件说明：
> 0. 证书生成脚本：[ssl-generater.sh](./tls/ssl-generater.sh)
> 1. etcd安装配置脚本：[k8s-etcd-install.sh](./k8s-etcd-install.sh)
> 2. master节点安装配置脚本：[k8s-master-install.sh](./k8s-master-install.sh)
> 3. node节点安装配置脚本：[k8s-node-install.sh](./k8s-node-install.sh)

> 集群安装步骤：
> 0. 执行tls下面的[ssl-generater.sh](./tls/ssl-generater.sh)，生成证书，然后将整个包压缩scp到各个节点
> 1. 执行[k8s-etcd-install.sh](./k8s-etcd-install.sh)，安装etcd分布式键值存储
> 2. 执行[k8s-master-install.sh](./k8s-master-install.sh)，安装k8s-master节点
> 3. 执行[k8s-node-install.sh](./k8s-node-install.sh)，安装k8s-node节点

各组件默认开机自启\
[kubernetes组件介绍](./k8s对象介绍.md)
[脚本安装示例](https://blog.csdn.net/mygirle/article/details/90678962)
[docker镜像push到nexus\mavenpush镜像到nexus](https://blog.csdn.net/mygirle/article/details/90516935)
