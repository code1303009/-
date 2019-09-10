```
@autoreleasePool{
    obj
}
```
autoreleasePool本质上是在 **{** 时调用函数构造方法**objc_autoreleasePoolPush**，又在 **}** 时调用的析构函数方法 **objc_autoreleasePoolPop**。这两个方法的源码如下

```
void *
objc_autoreleasePoolPush(void)
{
    return AutoreleasePoolPage::push();
}

void
objc_autoreleasePoolPop(void *ctxt)
{
    AutoreleasePoolPage::pop(ctxt);
}
```
看源码知道，push和pop都依赖于一个结构体**AutoreleasePoolPage**
```
class AutoreleasePoolPage 
{
    PAGE_MAX_SIZE；
    magic_t const magic;
    id *next;
    pthread_t const thread;
    AutoreleasePoolPage * const parent;
    AutoreleasePoolPage *child;
    uint32_t const depth;
    uint32_t hiwat;
}
```
**AutoreleasePoolPage**本质上是这么个结构，是一个双向链表
1. PAGE_MAX_SIZE是4096
2. 前七个变量都是8字节，剩下的4040用来存放autorelease对象
3. <# AutoreleasePoolPage * const parent #>，<#AutoreleasePoolPage *child#>；当4040字节不够用的时候，child会向下扩展一个新的autoreleasePoolPage，由此看来是双向链表结构
4. next指针指向当前autorelease对象的地址，每push一个对象，next++
5.
<#hotPage( )#>  : 当前AutoreleasePoolPage
<#coldPage( )#>  : 非当前AutoreleasePoolPage

## 与runloop、子线程关系

1. 主线程默认开始runloop，runloop会自行创建autoreleasePool，进行push、pop内存管理
2. 子线程默认不开启runloop，当产生autorelase对象的时候，会自行将对象添加到autorelasePoolPage，进行管理
3. **NSOperation**和**NSThread**需要手动创建autoreleasepool，比如NSOperation中的main方法里就必须有autoreleasepool，否则会有内存泄漏；
而**NSBlockOperation**和**NSInvocationOperation**这种默认的Operation就不需要我们创建，系统已经帮我们创建好了
4. autoreleasepool是按线程一一对应的，AutoreleasePoolPage结构里有 <#pthread_t const thread#> 跟线程关联，每开一个线程会有与之对应的autoreleasepool

对象全部销毁，autoreleasepool也会销毁
