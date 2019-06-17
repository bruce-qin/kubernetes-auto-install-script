#创建nfs共享存储卷
>创建共享目录：\
`mkdir /home/nfs` 

>安装nfs工具：\
`yum -y install nfs-utils`

>授权：\
`chmod -R 777 /home/nfs/`

>挂载共享目录：\
`echo "/home/nfs *(rw,no_root_squash,sync)" >> /home/nfs && exportfs -r`

>启动服务：\
`systemctl restart rpcbind && systemctl enable rpcbind`\
`systemctl restart nfs && systemctl enable nfs`

>客户端挂载nfs网络存储：\
`echo "[[nfs 主机ip]] nfs.st.local" >> /etc/hosts`\
`yum -y install autofs`\
`echo "/-    /etc/auto.mount" >> /etc/auto.master`\
`echo "/home/nfs/ -fstype=nfs,rw  nfs.st.local:/home/nfs/" >> /etc/auto.mount`\
`systemctl restart autofs  && systemctl enable autofs `

kubernetes 创建pv时一点要先创建nfs挂载文件夹，不然启动不了pod