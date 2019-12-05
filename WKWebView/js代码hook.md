## iOS对js代码hook 
1. **端内WKWebview初始化时**
    - 设置WKUserScript，生成要篡改的js代码或方法（方法内部调用自己本地的handler），
    - 将WKUserScript关联到WKWebview的WKUserContentController
    - 通过WKWebview的configuration的userContentController添加关联handler
2. **设置js的回调方法**
```
    - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
```
3. **通过safari捕获js源代码**
    获取navigator.geolocation.getCurrentPosition方法，截取实现在步骤2中，回抛js代码，捕获js代码可以参考<https://www.jianshu.com/p/ed4b1bfb57dc>
    
附上：拦截web页面定位弹框频繁弹出[demo](https://github.com/code1303009/learning-recording/tree/master/WKWebView/WKWebViewTest)
---
PS: demo需要切换到自己的证书，并且只有真机验证才会出现效果，模拟器无效
