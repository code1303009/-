
由于一时兴起，买了个搬瓦工的vps，就动手搭建一个vpn供自己和友人学习进步使用，以下是一些流程操作，略做笔记。

**1.打开搬瓦工网站，购买自己的vps**
> https://bwh8.net/index.php

**2.选择我的服务--进入KiwiVM Control Panel**

  我的服务
  进入KiwiVM

**3.如下图，进入control界面，直接是启用状态，全部都配置好了，有需求可以在Install new OS切换服务**

KiwiVM control

**4.同时你的邮箱回有一封密码的邮件**

邮件，密码

**5.下边就到了我们用ssh进入vps服务器，设置一下多账号信息,打开item**

> ssh -p xxxx root@NNnn

xxxx 改为你vps给的端口号

NNnn 改为你购买的vps的ip

例如： ssh -p 1086 root@192.168.0.1

然后回车，这时候需要第四步邮箱的密码，复制登入就可以了。

**6.接下来安装shadowsocks客户端，没安装就可以操作如下指令,如果已有直接进入第7步**

> yum install epel-release
>  yum update 
>  yum install python-setuptools m2crypto supervisor 
>  easy_install pip 
>  pip install shadowsocks

**7.配置shadowsocks.json文件**

> vi /etc/shadowsocks.json

终端编辑器使用若不会，请自行查阅资料，内容如下

> {
	"port_password":
	{
		"2333":"mima12345",
		"6666":"mima23456"
	},
	"timeout":300,
	"method":"aes-256-cfb",
	"fast_open": false
}

上边的json是建立了2个账号，分别的端口是2333和6666，对应的密码分别是mima12345和mima23456，然后:wq保存退出

**8.添加到进程，如果上边安装shadowsocks中supervisord安装成功了，执行如下指令；否则直接跳到第9步**

> vi /etc/supervisord.conf

  然后输入如下指令，保存退出

> [program:shadowsocks]
command=ssserver -s ::0 -d restart -c /etc/shadowsocks.json
autostart=true
autorestart=true
user=root
log_stderr=true
logfile=/var/log/shadowsocks.log


**9.设置开机启动项，输入如下指令**

> vi /etc/rc.local

进入后，如果supervisord是安装成功的，编辑器内容如下

> #!/bin/bash
touch /var/lock/subsys/local
/usr/bin/setterm -blank 0 || true
/usr/bin/ssserver -c /etc/shadowsocks.json -d restart

/usr/bin/ssserver -c /etc/shadowsocks.json -d restart 这句话是应用我们配置的shadowsock.json的配置，并重启

**10.重启服务器即可**
> reboot

**平时维护：**

增删账号只需要进入/etc/shadowsocks.json进行修改即可；
修改后执行重启命令ssserver -c /etc/shadowsocks.json -d restart。

**注：近期gwf2.0升级导致原地址被墙，重新换了新的ip重设服务。**

**安装如果在卡在第6部的pip install shadowsocks这一步，两种解决方法：**
> 1.脚本手动去安装shadowsocks，参考https://teddysun.com/342.html/comment-page-2 
> 2.一般情况下会卡在第6部easy_install pip。

这是因为Centos 6的Python版本是2.6.x导致pip9.0无法装最新版，手动下载安装pip9.0就可以了

  **解决：**

Centos６系统默认的python版本是２.6.x，可通过python --version来查看相关版本信息。
现在准备安装Python 2.7。
先运行下面的命令，安装一些必须的软件包
> sudo yum groupinstall "Development tools"
sudo yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel

官网下载Python安装包：
>wget https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tgz
>1. tar -zxvf Python-2.7.15.tgz
>2. cd Python-2.7.15
>3. ./configure --prefix=/usr/local
>4. make
>5. sudo make altinstall

然后编辑/usr/bin/yum，将第一行的#!/usr/bin/python修改成#!/usr/bin/python2.6
>ln -s /usr/local/bin/python2.7 /usr/bin/python

如果报错：
>ln: 创建符号链接 "/usr/bin/python": 文件已存在

删除 /usr/bin/python文件
>rm -rf /usr/bin/python

查看现在系统默认的python版本有没改为python2.7：
>python -V

**安装pip9.0.1**

pip是python的安装工具，很多python的常用工具，都可以通过pip进行安装。
要安装pip，首先要安装setuptools。下面的链接可以得到相关信息
https://pip.pypa.io/en/stable/installing/
https://packaging.python.org/tutorials/installing-packages/

 使用如下指令就好
>python -m ensurepip --default-pip
python -m pip install --upgrade pip setuptools wheel

 //安装pip
>curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
>python get-pip.py

下面就可以继续上面的第6步了。

 注：服务器net-speeder开启关闭指令
>chkconfig net_speeder on //开启
chkconfig net_speeder off //关闭

**2019年2月11日更新**

春节期间出现一部分自建vps的shadowsocks的账号登录不上，但是服务器ping和ss服务都是可用的。原因如下：
>国内最近墙了一批端口号，原来自建的shadowsocks的端口号不能用了，替换一下即可