> 底层：
>>Pod：
>>+ pod是最小部署单元，一个pod有一个或多个容器组成，pod容器空想存储和网络，在一台docker主机上运行。
>
>>Service：
>>+ service一个应用服务抽象，定义了pod逻辑集合和访问这个pod集合的策略。
>>- service代理pod集合对外表现是为一个访问入口，分配一个集群IP地址，来自这个IP的请求降幅在均衡转发到后端pod中的容器。
>>+ service通过lable selector选择一组pod提供服务。
>
>>Volume：
>>+ 数据卷，共享pod中容器使用的数据。
>
>>Namespace：
>>+ 命名空间将对象逻辑上分配到不同的Namespace，可以是不同的项目、用户等区分管理，并设定控制策略，从而实现多租户。
>>- 命名空间也称为虚拟集合。
>
>>Lable:
>>+ 标签用于区分对象（比如pod、service），键/值对存在；每个对象可以有多个标签，通过标签关联对象。


>顶层：
>>ReplicaSet：
>>+ 下一代Replication Controller。确保任何给定时间指定的Pod副本数量，并提供声明式更新等功能。
>>- RC与RS唯一区别就是lable selector支持不同，RS支持新的基于集合的标签，RC仅支持基于等式的标签。
>
>>Deployment：
>>+ Deployment是一个更高层次的API对象，它管理ReplicaSets和Pod，并提供声明式更新等功能。
>>- 官方建议使用Deployment管理ReplicaSets，而不是直接使用ReplicaSets，这意味着可能永远不需要直接操作ReplicaSet对象。
>
>>StatefulSet：
>>+ SatefulSet适合持久性的应用程序，有唯一的网络标识符（IP），持久存储，有序的部署、扩展、删除、和滚动更新。
>
>>DaemonSet：
>>+ DaemonSet确保所有（或一些）节点运行同一个Pod。当节点加入Kubernets集群中，Pod会被调度到该节点上运行，当节点从集群中移除是，DaemonSet的Pod会被删除。删除DaemonSet会清理它所有创建的Pod。
>
>>Job：
>>+ 一次性任务，运行完成后Pod销毁，不再重新启动形容器。还可以任务定时运行。
	

>Master节点：
>>kube-apiserver:
>>+ Kubernetes API,集群的统一入口，各组件协调者，以HTTP API提供接口服务，所有对象资源的增删改查和监听操作都交给APIServer处理后在提交给Etcd存储。
>	
>>kube-controller-manager:
>>+ 处理集群中常规后台任务，一个资源对应一个控制器，而ControllerManager就是负责管理这些控制器的。
>
>>kube-scheduler:
>>+ 根据调度算法为新创建的Pod选择一个Node节点。

>Node节点：
>>kubelet:
>>+ kubelet是Master在Node节点上的Agent，管理本机运行容器的生命周期，比如创建容器、Pod挂载数据卷、下载secret、获取容器和节点状态等工作。kubelet将每个Pod转换成一组容器。
>
>>kube-proxy:
>>+ 在Node节点上实现Pod网络代理，维护网络规则和四层负载均衡工作。
>
>>flannel：
>>+ kubelet node节点之间的网络通讯
>
>>docker或rocket/rkt:
>>+ 运行容器。
	
>第三方服务：
>>etcd:
>>+ 分布式键值存储系统。用于保持集群状态，比如Pod、Service等对象信息。
