   > Grand Central Dispatch(GCD) 是 Apple 开发的一个多核编程的较新的解决方法。它主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。它是一个在线程池模式的基础上执行的并发任务。在 Mac OS X 10.6 雪豹中首次推出，也可在 iOS 4 及以上版本使用。

**gcd优点**
```
GCD 可用于多核的并行运算
GCD 会自动利用更多的 CPU 内核（比如双核、四核）
GCD 会自动管理线程的生命周期（创建线程、调度任务、销毁线程）
程序员只需要告诉 GCD 想要执行什么任务，不需要编写任何线程管理代码
```
**主要用法**
**创建**
```
//串行队列的创建方法
    dispatch_queue_t queue = dispatch_queue_create("111111", DISPATCH_QUEUE_SERIAL);
//并发队列的创建方法
    dispatch_queue_t queue2 = dispatch_queue_create("2222", DISPATCH_QUEUE_CONCURRENT);
// 主队列的获取方法
    dispatch_queue_t queue = dispatch_get_main_queue();
// 全局并发队列的获取方法
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
// 同步执行任务创建方法
    dispatch_sync(queue, ^{
        // 这里放同步执行任务代码
    });
// 异步执行任务创建方法
    dispatch_async(queue, ^{
        // 这里放异步执行任务代码
    });
```
**gcd栅栏方法 dispatch_barrier_async**
我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于 栅栏 一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。
```
/**
* 栅栏方法 dispatch_barrier_async
*/
- (void)barrier {
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
    // 追加任务1
        for (int i = 0; i < 2; ++i) {
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
            }
    });
    dispatch_async(queue, ^{
    // 追加任务2
        for (int i = 0; i < 2; ++i) {
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_barrier_async(queue, ^{
    // 栅栏 barrier
        for (int i = 0; i < 2; ++i) {
            NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
        }
    });

    dispatch_async(queue, ^{
    // 追加任务3
        for (int i = 0; i < 2; ++i) {
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
    // 追加任务4
        for (int i = 0; i < 2; ++i) {
        NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
}
```

**GCD 延时执行方法：dispatch_after**
我们经常会遇到这样的需求：在指定时间（例如3秒）之后执行某个任务。可以用 GCD 的dispatch_after函数来实现。
需要注意的是：
```
dispatch_after函数并不是在指定时间之后才开始执行处理，而是在指定时间之后将任务追加到主队列中。
严格来说，这个时间并不是绝对准确的，但想要大致延迟执行任务，dispatch_after函数是很有效的。
```

```
/**
* 延时执行方法 dispatch_after
*/
- (void)after {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
}
```

**GCD 一次性代码（只执行一次）：dispatch_once**
```
/**
* 一次性代码（只执行一次）dispatch_once
*/
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行1次的代码(这里面默认是线程安全的)
    });
}
```

**GCD 快速迭代方法：dispatch_apply**
通常我们会用 for 循环遍历，但是 GCD 给我们提供了快速迭代的函数dispatch_apply。dispatch_apply按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束。
```
/**
* 快速迭代方法 dispatch_apply
*/
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}
```

**GCD 的队列组：dispatch_group**
主要用法：
```
dispatch_group_notify//监听 group 中任务的完成状态，当所有的任务都执行完成后，追加任务到 group 中，并执行任务。
dispatch_group_wait//暂停当前线程（阻塞当前线程），等待指定的 group 中的任务执行完成后，才会往下继续执行。
dispatch_group_enter// 标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数+1
dispatch_group_leave//标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数-1。

当 group 中未执行完毕任务数为0的时候，才会使dispatch_group_wait解除阻塞，以及执行追加到dispatch_group_notify中的任务。
```

**dispatch_group_notify**
```
/**
* 队列组 dispatch_group_notify
*/
- (void)groupNotify {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");

    dispatch_group_t group =  dispatch_group_create();

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 追加任务1
        for (int i = 0; i < 2; ++i) {
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 追加任务2
        for (int i = 0; i < 2; ++i) {
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    // 等前面的异步任务1、任务2都执行完毕后，回到主线程执行下边任务
        for (int i = 0; i < 2; ++i) {
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
        NSLog(@"group---end");
    });

}
```

**GCD 信号量：dispatch_semaphore**
```
dispatch_semaphore_create：创建一个Semaphore并初始化信号的总量
dispatch_semaphore_signal：发送一个信号，让信号总量加1
dispatch_semaphore_wait：可以使总信号量减1，当信号总量为0时就会一直等待（阻塞所在线程），否则就可以正常执行。
```
参考
>https://juejin.im/post/5a90de68f265da4e9b592b40#heading-20
