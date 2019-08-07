**【1】在判断手势是否点击进入时，可以在当前View中检查代理方法**
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event

**【2】dispatch_semaphore问题**
dispatch_semaphore不能作为成员变量被多线程共用，而是每次使用时都create(0)
dispatch_semaphore作为成员变量，当多线程多次调用retrieveSessionInfo，如果发生dispatch_semaphore_wait超时，semaphore平衡被打破，可能形成上一次的signal释放下一次的wait的情况

**【3】ios <Error>: CGAffineTransformInvert: singular matrix**

使用仿射变换时，出现这个错误，这个错误叫做奇异矩阵
原因之一是将缩放系数设置为0，0导致的
想去掉这个错误，就把缩放系数设置为大于0的数即可

**【4】UIView的阻尼动画**
//气泡弹出效果，阻尼0.6，幅度0.7
[UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
self.transform = CGAffineTransformMakeScale(1, 1);
self.frame = _showRect;
} completion:^(BOOL finished) {
self.frame = _showRect;
self.transform = CGAffineTransformIdentity;
_isShow = YES;
btn.selected = YES;
//在btn的selected属性发生改变时，发通知（KVO受限太多）
[[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ButtonSelectedChanged object:nil];
}];

**【5】KVO使用时坑非常多**
1、不能对一个对象多次设置KVO
2、不能多次释放一个对象的KVO
3、如果观察者被释放，KVO触发，crash
4、如果被观察者释放，KVO触发，crash

最终舍弃KVO，使用通知中心

**【6】干嘛这样用？**
```
dispatch_async(dispatch_get_main_queue(), ^{
    callback(newSession);
});
```
用来保证数据的顺序性，发一个请求，再发一个请求，两个请求如果返回的顺序有问题，可能会出现UI问题
之前解决过一个网络返回冲突问题，不能用主线程队列解决，因为有数据依赖，队列挂任务节点的时候传参也是空
如果多个网络返回的数据无依赖性，但要求顺序，则需要将其放进主线程队列中即可

**【7】手势进不去**
用gesture代理中的 should begin  代理方法，返回YES即可

**【8】TPDWeakProxy原理**
内部实现：
```
@interface TPDWeakProxy()
@property (weak, nonatomic) id weakProxy;
@end

@implementation TPDWeakProxy
- (instancetype)initWithWeakProxy:(id)obj {
    _weakProxy = obj;
    return self;
}
+ (instancetype)proxyWithWeak:(id)obj {
    return [[ZYWeakObject alloc] initWithWeakObject:obj];
}
```
```
/**
* 消息转发，让_weakProxy响应事件
*/
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _weakProxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_weakProxy respondsToSelector:aSelector];
}
```
```
    TPDWeakProxy *weakproxy = [[TPDWeakProxy alloc] initWithObject:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:weakproxy selector:@selector(timerFired) userInfo:nil repeats:YES];
```
使用TPDWeakProxy包装的target，传入NSTimer后，不会影响到调用dealloc方法
原因是TPDWeakProxy是一个虚类，这个类只负责进行消息转发，而并没有让timer持有target（使用虚类这个思路可以用来解决很多循环引用问题）

**【8.1】NSTimer循环引用还可以重写timer改用block解决，timer重写类内target内置调用self**
```
@implementation NSTimer (BlcokTimer)
+ (NSTimer *)bl_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(bl_blockSelector:) userInfo:[block copy] repeats:repeats];
}

+ (void)bl_blockSelector:(NSTimer *)timer {
    void(^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}
@end
```
```
__weak typeof(self) weakSelf = self;
self.timer = [NSTimer bl_scheduledTimerWithTimeInterval:1 block:^{
    [weakSelf changeText];
} repeats:YES];
```

**【9】代码埋点的方法**
可以通过hook基础控件实现，在执行原方法时，附加埋点
顺风车首页即为这种做法

**【10】延时执行方法：**
>[self performSelector:@selector(didRuninCurrModel:) withObject:[NSNumber numberWithBool:YES] afterDelay:3.0f];
viewWillDisappear时的取消延时执行方法
>[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didRuninCurrModel:) object:[NSNumber numberWithBool:YES]];
规则是：在挂延时执行方法和取消延时执行方法时，必须target，selector，arguments，argumentsValue完全一致，才可以精确取消

**【11】**
APNS和程序在不在后台前台无关，只要注册了就会收到

**【12】masonry和frame混合布局的时候没有两个坑**
1、masonry是在下一个runloop循环调起**layoutSubViews**的时候才会进行布局，所以刚刚进行完约束的控件不会立即得到frame属性，需要先设置setNeedsLayout和layoutIfNeeded才能够使用frame属性
2、自动布局使用的是constraint，constraint最终会计算为frame，但是直接使用frame布局是没有constraint的，所以在layoutSubView的时候拿不到frame布局的控件的任何属性，所以如果外部用自动布局写的，内部用frame布局写的，那么内部需要告知外部需要的高度/宽度等属性，以便外部masonry计算constraint完成布局

**【13】launchOptions中存储的什么**
>- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
说明：当应用程序启动时执行，应用程序启动入口。只在应用程序启动时执行一次。application参数用来获取应用程序的状态、变量等，值得注意的是字典参数：(NSDictionary *)launchOptions，该参数存储程序启动的原因。
若用户直接启动，lauchOptions内无数据;

**【14】UIView的setNeedsDisplay和setNeedsLayout方法**
首先两个方法都是异步执行的。而setNeedsDisplay会调用自动调用drawRect方法，这样可以拿到  UIGraphicsGetCurrentContext，就可以画画了。而setNeedsLayout会默认调用layoutSubViews，

就可以  处理子视图中的一些数据。

**【15】sizeToFit 和 sizeThatFits方法区别**
sizeToFit是苹果提供的视图自适应内容后，返回size的方法
sizeThatFits是可以由开发者覆写的，返回自定义size的方法

如果一个视图重写了sizeThatFits，则调用这个视图的sizeToFit时，会调到sizeThatFits里面来
sizeThatFits也可以被外部调用，提供给一个最大的size，sizeThatFits里面根据这个最大size进行适配，计算出实际应该返回的size

**【16】RAC的绑定监听方法**
##如果被监听的属性是第一次创建的话，则会出触发两次信号，第一次触发信号为nil，是因为初始化的时候会置空，所以我们的处理方式是skip掉第一次信号，用完之后将属性置为nil，然后每次监听时都产生一次nil的信号并被skip过滤掉

##RAC就像水流一样，如果最终没有容器去接水流，那么水就不会流动
>RAC(self.someLablel, text) = [[title catchTo:[RACSignal return:@"Error"]]  startWith:@"Loading...”];
例如这段代码，如果没有 = 前面这一段，= 后面的这段逻辑就不会进行

**【17】自定义导航栏**
需要将原生导航栏的navigationBar隐藏掉，如果不隐藏可能导致界面高度从h=64开始计算，这样得到的界面高度就比屏幕高度少64，计算错误
self.navigationController.navigationBarHidden = YES; 
self.edgesForExtendedLayout = UIRectEdgeNone; 【？】
self.navigationController.navigationBar.translucent = NO; 【导航条透明度相关】

**【18】Xcode打开内存选项**
editSheme->Diagnostics->只打开Malloc Stack

**【19.0】semaphore详解**
```
dispatch_semaphore_t dispatch_semaphore_create(long value);
long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout);
long dispatch_semaphore_signal(dispatch_semaphore_t dsema);
```
**dispatch_semaphore_create####**
创建一个新的信号量，参数value代表信号量资源池的初始数量。
```
value < 0， 返回NULL
value = 0, 多线程在等待某个特定线程的结束。
value > 0, 资源数量，可以由多个线程使用。
```
**dispatch_semaphore_wait####**
等待资源释放。如果传入的dsema大于0，就继续向下执行，并将信号量减1；如果dsema等于0，阻塞当前线程等待资源被dispatch_semaphore_signal释放。如果等到了信号量，继续向下执行并将信号量减1，如果一直没有等到信号量，就等到timeout再继续执行。dsema不能传入NULL。
timeout表示阻塞的时间长短，有两个常量：**DISPATCH_TIME_NOW表示当前**，**DISPATCH_TIME_FOREVER表示永远**。

**dispatch_semaphore_signal####**
释放一个资源。返回值为0表示没有线程等待这个信号量；返回值非0表示唤醒一个等待这个信号量的线程。如果线程有优先级，则按照优先级顺序唤醒线程，否则随机选择线程唤醒。

**应用场景**
```
1.方法内异步请求后return返回
2.方法内相册资源转格式返回
3.内存读写操作等
```

**【19】同步状态下的semaphore信号锁写法**
全局持有：
>static dispatch_semaphore_t _lock；
初始化
>_lock = dispatch_semaphore_create(1);
用时加锁：
>dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
用时解锁：
>dispatch_semaphore_signal(_lock);

**【20】异步状态下的semaphore信号锁写法**
```
dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
if (block) block(^{
    dispatch_semaphore_signal(semaphore);
});
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER));
```

**【21】UIView.layer.shouldRasterize = YES** CALayer会被光栅化为bitmap,layer的阴影等效果也会被缓存到bitmap中，等下次使用时不会再重新去渲染了。实现圆角本身就是在做颜色混合（blending），如果每次页面出来时都blending，消耗太大，这时shouldRasterize = yes，下次就只是简单的从渲染引擎的cache里读取那张bitmap，节约系统资源。
额外收获：如果在滚动tableView时，每次都执行圆角设置，肯定会阻塞UI，设置这个将会使滑动更加流畅。
**参考链接**
>https://blog.csdn.net/lg767201403/article/details/50960909
>https://github.com/100mango/zen/blob/master/WWDC%E5%BF%83%E5%BE%97%EF%BC%9AAdvanced%20Graphics%20and%20Animations%20for%20iOS%20Apps/Advanced%20Graphics%20and%20Animations%20for%20iOS%20Apps.md

**【22】view响应子控件超边距事件**
重写父view的hitTest:withEvent:方法，直接上代码
```
/**
*  响应子控件超边距事件
*/
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = [super hitTest:point withEvent:event];
    if (!v) {
        for (UIView *subview in self.subviews) {
            // 转化point为子控件坐标
            CGPoint p = [subview convertPoint:point fromView:self];
            // 坐标在子控件内 回应
            if (CGRectContainsPoint(subview.bounds, p)) {
                v = subview;
                break;
            }
        }
    }
    return v;
}
```
