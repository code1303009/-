之前，很多朋友是用苹果手机想要翻墙，可是遇到大多问题是vpn软件收费不好用，今天就给大家介绍一款免费的vpn工具，翻墙vpn账号请自行搭建或购买，该文只介绍使用。

1.界面如图

![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/logo.png)

![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/界面.png)

2.点开配置栏，有两行代理和规则

![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/配置.png)

3.点击加号，添加新代理，默认界面如下，楼主用的Shadowsocks的，就直接默认了，具体详情咨询你vpn的配置。楼主这里要建立2个代理，一个是翻墙的取名vps，一个国内直连的叫Direct。

![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/添加翻墙代理.png)


![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/选择翻墙的代理方式.png)


![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/国内直连代理.png)

4.操作完成之后，回到配置首页，我们去配置一下相关规则


![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/配置首页.png)


选择新规则类型
这个时候，因为我们配置的是2个代理，默认国内网址走的是direct直连方式，这样会比较快，方式选Country，如下界面，勾选DIrect

![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/国内直连规则.png)


下边是vpn规则，除了国内的网址，其余都走vpn，所以方式选All，代理选择我们之前建立的vps

![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/vpn规则.png)


5.配置完成之后，规则上勾上对号，然后在状态页面开启就可以了

![image](https://github.com/code1303009/learning-recording/raw/master/vpn/AppStore%E5%85%8D%E8%B4%B9vpn%E5%B7%A5%E5%85%B7Detour%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/images/配置完成.png)


注意：因为detour默认是走规则的，必须配置规则。规则从上到下，去自动匹配对应的代理。所以我们上边的顺序是，先去判断是否国内，是就走国内直连，不是国内网站就直接走代理。
