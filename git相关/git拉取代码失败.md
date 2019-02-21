前几天接手新项目，clone项目的时候遇到clone文件拉不下代码的情况，报错如下：

```
error: RPC failed; curl 18 transfer closed with outstanding read data remaining

fatal: The remote end hung up unexpectedly

fatal: early EOF

fatal: index-pack failed
```

然后就网上各种查，因为我checkout代码使用的是http网址形式，所以很自然的搜到了网上流行的那种说法，数据量太大postBuffer太小拉不下来代码导致。

网上的解决方法：

```
git config –global http.postBuffer 524288000
```

然而，并没有什么卵用。

主要问题是出在git服务器上没有你的ssh key，本地找一下ssh key到git服务器配置一下就好了。因为本地有ssh key直接上图



![image](https://github.com/code1303009/learning-recording/raw/master/git%E7%9B%B8%E5%85%B3/images/查找本地ssh-rsa.png)

然后，就是把rsa到配置到github的Settings -->SSH keys -->Add SSH key就可以正常clone了。注：先用ssh的网址clone。