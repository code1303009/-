//
//  ViewController.m
//  wkwebviewTest
//
//  Created by wei.jiang on 2019/12/4.
//  Copyright © 2019 wei.jiang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     NSString *jScript = @"navigator.geolocation.getCurrentPosition = function(success, error, options) {window.webkit.messageHandlers.locationHandler.postMessage('getCurrentPosition');};";
     WKUserScript *scaleToFitScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
     WKUserContentController *userContent = [[WKUserContentController alloc] init];
     [userContent addUserScript:scaleToFitScript];
     
     WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
     webConfig.allowsInlineMediaPlayback = YES;//允许网页里，播放多媒体
     webConfig.userContentController = userContent;
     webConfig.mediaPlaybackRequiresUserAction = NO;
     webConfig.allowsAirPlayForMediaPlayback = YES;
     WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:webConfig];
     wkWebView.navigationDelegate = self;
     wkWebView.UIDelegate = self;
    
     wkWebView.backgroundColor = [UIColor clearColor];
     wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     if (wkWebView.configuration.userContentController) {
         [wkWebView.configuration.userContentController addScriptMessageHandler:(id)self name:@"locationHandler"];
     }
    
    _webview = wkWebView;
    [self.view addSubview:_webview];
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://luna.58.com/list.shtml?plat=m&city=bj&cate=shouji&-15=20&utm_source=link&spm=m-29808017352203-ms-f-673.mes_sj_wymsh_ios_esw_sjpj"]]];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"%@",message.name);
    NSLog(@"%@",message.body);
    if ([message.name isEqualToString:@"locationHandler"]) {
        if ([message.body isKindOfClass:[NSString class]] && [message.body isEqualToString:@"getCurrentPosition"]) {
            NSString *jsScript = @"\
            /*定位成功回调函数*/\
            function(position){\
                if (typeof window.clickLog === 'function') {\
                    window.clickLog('from=lbs_data_list_success_' + config.cate + '_' + position.coords.accuracy);\
                };\
                var latitude  = position.coords.latitude,/*获取纬度*/\
                    longitude = position.coords.longitude,/*获取经度*/\
                    service_url = \"//m.58.com/location/?l=\" + latitude + \"&d=\" + longitude + \"&callback=?\";/*拼接主站获取城市参数的请求url*/\
                    activeCityName = ____json4fe.locallist[0].listname;\
                $.ajax({\
                    url: service_url,\
                    dataType: 'jsonp',\
                    success: function(data) {\
                        if(typeof data != \"object\" || data.listname.length === 0) return;\
                        /*调用城市参数比对方法*/\
                        judgeCity(data.listname, data.cityname);\
                    },\
                    /*ajax失败回调函数*/\
                    error: function () {\
                        /*调用后端ip定位接口方法*/\
                        ipLocation();\
                    }\
                });\
            },\
            /*定位失败回调函数*/\
            function(error){\
                /*调用后端ip定位接口方法*/\
                ipLocation();\
            },\
            {\
                timeout: 2e3,\
                maximumAge: 6e4,\
                enableHighAccuracy: true\
            }";
            [[self webview] evaluateJavaScript:jsScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                NSLog(@"%@",result);
                NSLog(@"%@",error);
                ;
            }];
        }
    }
}


#pragma mark - WKNavigationDelegate
//allow or cancel request -判断，是否允许发起请求
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}


// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}

// 内容返回时
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}

//成功
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}

//失败
- (void)webView:(WKWebView *)webView didFailNavigation: (null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}
#pragma mark - web UI delegate
/*  警告 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // web 调用 js，并等待结果
}

///** 确认框 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
}
/**  输入框 */
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
//    [[[UIAlertView alloc] initWithTitle:@"输入框" message:prompt delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil] show];
//    completionHandler(@"你是谁！");
//}
// 创建新的webView
// 可以指定配置对象、导航动作对象、window特性。如果没用实现这个方法，不会加载链接，如果返回的是原webview会崩溃。
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// webview关闭时回调
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0) {
}

@end
