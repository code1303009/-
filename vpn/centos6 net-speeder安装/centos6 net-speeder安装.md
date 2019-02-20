github地址 https://github.com/snooda/net-speeder

net-speeder 简介
net-speeder可以在高延迟不稳定链路上优化单线程下载速度。运行时依赖的库：libnet、libpcap 。安装教程github上有，这里只讲centos6的安装，并且针对出现的问题做一下记录。

#安装步骤：

##1：进入服务器内部

```
ssh -p xxxx root@NNnn
```

xxxx 改为你vps给的端口号 

NNnn 改为你购买的vps的ip 

##2：下载源码并解压

```
wget https://github.com/snooda/net-speeder/archive/master.zip

unzip master.zip
```

##3：准备编译环境

###①#下载epel：https://fedoraproject.org/wiki/EPEL/zh-cn 例：CentOS6 64位：

```
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
```

**如果是centos5，则在epel/5/下**

###②#安装epel：

```
rpm -ivh epel-release-6-8.noarch.rpm
```

###③#然后即可使用yum安装：

```
yum install libnet libpcap libnet-devel libpcap-devel
```

**注：这里可能出现问题的是3-3这一步，在安装libnet的时候出现libnet not available的问题，解决方法就是重装epel。**

```
rm -rf /var/cache/yum/x86_64/6/epel

yum remove epel-release

yum update
```

#安装epel： 

```
rpm -ivh epel-release-6-8.noarch.rpm 
```

#然后即可使用yum安装：

```
 yum install libnet libpcap libnet-devel libpcap-devel 
```

##4: 编译

#然后进到/net-speeder-master/目录下 

```
chmod +x build.sh

./build.sh 
```

##5: 运行

#使用下面的代码运行，加速所有的ip，启动：

```
/usr/bin/net_speeder venet0 "ip" 
```

#如果网卡是eth0应该这么写，用ifconfig指令查看网卡类型（venet0 / eth0）

```
/usr/bin/net_speeder eth0 "ip"  
```

##6: 重启服务

```
reboot
```

##7: 开启ss服务

```
ssserver -c /etc/shadowsocks.json -d restart
```