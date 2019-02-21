之前电脑装过cocoapods，后来删掉了重新安装怎么装都会报如下错误：
```
ERROR: Could not find a valid gem 'cocoapods' (>= 0) in any repository
```
然后，就去搜这个问题，敲命令行
```
gem sources -l
```
查看ruby源之后，发现是 http://ruby.taobao.org/, 源的版本已经被淘宝forbidden了，返回404，所以就换源
```
gem sources -a https://ruby.taobao.org/
```
之后又发现又爆了如下的错误：
```
ERROR:  While executing gem ... (Gem::Exception)

Unable to require openssl, install OpenSSL and rebuild ruby (preferred) or use non-HTTPS sources
```
从上边发现需要

**1.安装OpenSSL然后重新编译ruby**

**2.使用非http的源**

我们的源已经是https的了，所以需要openssl。从网友们的搜索知道了原因，是因为mac自带的ruby，但是ruby没有给OpenSSL配置相应的环境变量。

想要简单的做法就是安装rvm，通过RVM来安装ruby，这样RVM就会自动给你配置好相应的OpenSSL参数。

而RVM安装的步骤就是**Xcode->homebrew->RVM->Ruby->CocoaPads**

xcode不用说，homebrew是一个包管理器，用于在mac上安装一些os x上没有的UNiX工具（比如wget）（wget我不知道是什么），但是作为一个菜鸟来说，只要知道它如同window的350软件管理器就行了，用来安装一些软件。


**homebrew安装：**

安装homebrew的方法非常简单，打开官方网站，在下面有一条安装指令：
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
然后会出现如下代码：
```
==> This script will install:

/usr/local/bin/brew

/usr/local/share/doc/homebrew

/usr/local/share/man/man1/brew.1

/usr/local/share/zsh/site-functions/_brew

/usr/local/etc/bash_completion.d/brew

/usr/local/Homebrew

==> The following existing directories will be made group writable:

/usr/local/lib/pkgconfig

==> The following existing directories will have their owner set to xxxxx:

/usr/local/lib/pkgconfig

==> The following existing directories will have their group set to admin:

/usr/local/lib/pkgconfig

==> The following new directories will be created:

/usr/local/Homebrew

/usr/local/Frameworks

/usr/local/sbin

/usr/local/share/zsh

/usr/local/share/zsh/site-functions

/usr/local/var

Press RETURN to continue or any other key to abort
```
然后直接回车就可以开始安装homebrew了，安装完成之后就开始安装RVM。

安装RVM：
```
curl -L https://get.rvm.io | bash -s stable
```
期间可能会问你sudo管理员密码，以及自动通过homebrew安装依赖包，等待一段时间后就可以成功安装好 RVM。 然后，载入 RVM环境
```
source ~/.rvm/scripts/rvm
```
检查一下是否安装正确
```
rvm -v
```
检查RVM是否最新版本，如果不是最新版本，执行如下命令更新到最新版本：
```
rvm reload
```
安装 Ruby；
```
rvm install 2.0.0
```
同样继续等待漫长的下载，编译过程，完成以后，Ruby, Ruby Gems就安装好了。

这个时候的ruby是2.0.0不是最新版本，所以需要自己手动更新到最新的版本。
```
rvm install ruby 2.4.1
```
因为楼主最新版本是2.4.1所以就更新到2.4.1。这个时候ruby安装好了，同事OpenSSL也相应的配置好了，这时候就可以更换ruby源了。
```
gem source -a https://ruby.taobao.org
```
之后就出现如下
```
https://ruby.taobao.org added to sources
```
证明添加成功了，然后我们就可以愉快的执行cocoapods安装了
```
sudo gem install cocoapods
```
漫长等待之后，cocoaPods初期安装就好了，这个时候：
```
pod setup (这一步是在网上下载所需文件,需等待较长时间,取决于你当前的网速)
```
安装后就可以上使用cocoapods了.


**后期补充**

rvm install 2.0.0这一步可能出现这样的错误：
```
error: RPC failed; curl 56 SSLRead() return error -9806
```

**解决方案：**
```
brew remove git

brew remove curl

brew install openssl

brew install --with-openssl curl

brew install --with-brewed-curl --with-brewed-openssl git  //这行代码可能下载文件较大一直失败，重复尝试就好 应该是后端有一个下载超时的限制
```

另外，更新mac系统之后已经不能再用
```
sudo gem install  cocoapods
```
新版的pod安装指令是这样的
```
sudo gem install -n /usr/local/bin cocoapods
```
但是可能会出现这样的错误
```
ERROR:  While executing gem ... (Gem::DependencyError)

Unable to resolve dependencies: cocoapods requires cocoapods-core (= 1.2.1), cocoapods-downloader (< 2.0, >= 1.1.3), cocoapods-trunk (< 2.0, >= 1.2.0), molinillo (~> 0.5.7), xcodeproj (< 2.0, >= 1.4.4), colored2 (~> 3.1), ruby-macho (~> 1.1)
```
这时候执行
```
sudo gem update --system
```
出现RubyGems system software updated就ok了，继续执行
```
sudo gem install -n /usr/local/bin cocoapods  
```
搞定收工。