
已有自建vpn，可供浏览器翻墙，自己用的是shadowsocks翻墙，参考链接如下
>https://github.com/shadowsocks/ShadowsocksX-NG

**这里只是介绍自用翻墙方式，直接写入bash_profile，避免关闭终端就失效的情况

打开文件
```
vim ~/.bash_profile
```

macOS 版的 SS 默认监控本地的HTTP端口是 1087，而 Windows 版本的则是 1080，如果改过默认端口，就使用你指定的端口

**配置bash_profile代理开关方法

```
function proxy_off(){
   unset http_proxy
   unset https_proxy
   echo -e "已关闭代理"
}

function proxy_on(){
   export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
   export http_proxy="http://127.0.0.1:1087"
   export https_proxy="http://127.0.0.1:1087"
   echo -e "已开启代理"
}
```
:wq保存退出bash_profile

**配置生效
```
source ~/.bash_profile
```

**开启代理
```
proxy_on
```

**关闭代理
```
proxy_off
```

