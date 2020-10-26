 ## 闭包 ##
 >* 全局函数是一个有名字但不会捕获任何值的闭包
 >* 嵌套函数是一个有名字并可以捕获其封闭函数域内值的闭包
> * 闭包表达式是一个利用轻量级语法所写的可以捕获其上下文中变量或常量值的匿名闭包
  
 ##### 闭包是对函数的优化 
 >* 利用上下文推断参数和返回值类型
 >* 隐式返回单表达式闭包，即单表达式闭包可以省略 return 关键字
 >* 参数名称缩写
 >* 尾随闭包语法

## 闭包表达式语法[](#closure-expression-syntax)
闭包表达式语法有如下的一般形式：
```
{ (parameters) -> return type in
    statements
}
```
## 缩写
```
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
func backward(_ s1: String, _ s2: String) -> Bool {
    return s1 > s2
}
var reversedNames = names.sorted(by: backward)
reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in return s1 > s2 })
reversedNames = names.sorted(by: { s1, s2 in return s1 > s2 } )
reversedNames = names.sorted(by: { s1, s2 in s1 > s2 } )
// reversedNames 为 ["Ewa", "Daniella", "Chris", "Barry", "Alex"]
```
##### 参数名称缩写[](#shorthand-argument-names)
> Swift 自动为内联闭包提供了参数名称缩写功能，你可以直接通过 ```$0```，```$1```，```$2``` 来顺序调用闭包的第一、二、三个参数，以此类推。
```
reversedNames = names.sorted(by: { $0 > $1 } )
```
在这个例子中，```$0``` 和 ```$1```表示闭包中第一个和第二个 String 类型的参数。

##### 运算符方法[](#operator-methods)
Swift 的 ```String``` 类型定义了关于大于号（```>```）的字符串实现，其作为一个函数接受两个 ```String``` 类型的参数并返回 ```Bool``` 类型的值。而这正好与 ```sorted(by:) ```方法的参数需要的函数类型相符合。因此，你可以简单地传递一个大于号，Swift 可以自动推断找到系统自带的那个字符串函数的实现：
```
reversedNames = names.sorted(by: >)
```
## 尾随闭包
如果你需要将一个很长的闭包表达式作为最后一个参数传递给函数，将这个闭包替换成为尾随闭包的形式很有用。
尾随闭包是一个书写在函数圆括号之后的闭包表达式，函数支持将其作为最后一个参数调用。在使用尾随闭包时，你不用写出它的参数标签：
```
func someFunctionThatTakesAClosure(closure: () -> Void) {
    // 函数体部分
}

// 以下是不使用尾随闭包进行函数调用
someFunctionThatTakesAClosure(closure: {
    // 闭包主体部分(适用于闭包主体部分短小)
})

// 以下是使用尾随闭包进行函数调用
someFunctionThatTakesAClosure() {
    // 闭包主体部分（适用于闭包主体部分过长）
}
```
如果闭包表达式是函数或方法的唯一参数，则当你使用尾随闭包时，你甚至可以把 () 省略掉：
```
func exec(fn : (Int,Int) -> Int){
    print(fn(1,2))
}
exec(fn :{$0 + $1})
exec(){$0 + $1}
exec{ $0 + $1 }
```
## 值捕获
闭包可以在其被定义的上下文中捕获```常量```或```变量```。即使定义这些常量和变量的```原作用域已经不存在```，闭包仍然可以在闭包函数体内`引用`和``修改这些值``。
* 一般指定义在函数内部的函数
* 一般它捕获的是外层函数的局部变量或常量
```
typealias Fn = (Int) -> Int
//函数形式
func getFn() -> Fn {
    //局部变量
    var num = 0
    func plus(_ i:Int) -> Int{
        //对局部变量的修改操作 触发了内存拷贝操作 将局部变量copy到了堆上进行存储
        num += i
        return num
    }
    return plus
}
//闭包形式
func getFn2() -> Fn {
    //局部变量
    var num = 0
    return {
        num += $0
        return num
    }
}

var fn1 = getFn()
print(fn1(1))//1
print(fn1(2))//3
print(fn1(3))//6
print(fn1(4))//10
var fn2 = getFn2()
print(fn2(1))//1
print(fn2(2))//3
print(fn2(3))//6
print(fn2(4))//10

```
上边的例子，`num`变量放在`getFn()`函数之外结果也是一样的。

**可以把闭包类比成一个类的实例对象**
* 内存在堆空间
* 捕获的局部变量/常量就是对象的成员（存储属性）
* 组成闭包的函数就是类内定义的方法
```
// 上边的闭包可以转化成下边代码去理解
class Closure{
    var num = 0
    func plus(_ i: Int) -> Int {
        num += i
        return num
    }
}
var cs1 = Closure()
cs1.plus(1)//1
cs1.plus(2)//3
cs1.plus(3)//6
cs1.plus(4)//10
```
>注意
> 如果你将闭包赋值给一个类实例的属性，并且该闭包通过访问该实例或其成员而捕获了该实例，你将在闭包和该实例间创建一个循环强引用。Swift 使用捕获列表来打破这种循环强引用。更多信息，请参考 [闭包引起的循环强引用](/swift/swift-jiao-cheng/24_automatic_reference_counting#strong-reference-cycles-for-closures)。

## 逃逸闭包`@escaping` 
待补全
## 自动闭包
待补全

===========================================
## 闭包的循环引用
###### 发生场景：
当你将一个闭包赋值给类实例的某个属性，并且这个闭包体中又使用了这个类实例时。导致了闭包“捕获”`self`，从而产生了循环强引用。


### 自动引用计数相关
#### 1. 弱引用`Weak`
修饰的类型为`可选类型变量`，引用对象销毁时，对象自动置`nil`

###### 使用场景：
`a`、`b`两个类互相引用，但互相引用的两个属性值都允许为`nil`,并会潜在的产生循环强引用。这种场景最适合用`弱引用`来解决。
```
class Person {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment?
    deinit { print("\(name) is being deinitialized") }
}

class Apartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    weak var tenant: Person?
    deinit { print("Apartment \(unit) is being deinitialized") }
}

var john: Person? = Person(name: "John Appleseed")
var unit4A: Apartment? = Apartment(unit: "4A")

john!.apartment = unit4A
unit4A!.tenant = john

// 释放
john = nil
//打印 "John Appleseed is being deinitialized"
```
![image.png](https://upload-images.jianshu.io/upload_images/19675505-7d0039e05f5ae97c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 2. 无主引用`Unowned`
和弱引用类似，无主引用不会牢牢保持住引用的实例。但区别的是，无主引用在其他实例有`相同或者更长的生命周期时`使用。
无主引用通常都被期望拥有值。不过 ARC 无法在实例被销毁后将无主引用设为 `nil`，因为`非可选类型的变量`不允许被赋值为` nil`。

> **重点**
>使用无主引用，你必须确保引用始终指向一个`未销毁的实例`。
>如果你试图在实例被销毁后，访问该实例的无主引用，会触发`运行时错误`。

###### 使用场景：
`a`、`b`两个类相互引用，一个属性的值允许为 `nil`，而另一个属性的值不允许为` nil`，这也可能会产生循环强引用。这种场景最适合通过`无主引用`来解决。
```
// unowned场景
class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit { print("\(name) is being deinitialized") }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit { print("Card #\(number) is being deinitialized") }
}

let useOfficial = false

if useOfficial {
    var Appleseed: Customer? = Customer(name: "John Appleseed")
    Appleseed!.card = CreditCard(number: 1234_5678_9012_3456, customer: Appleseed!)

    Appleseed = nil
    // 打印“John Appleseed is being deinitialized”
    // 打印“Card #1234567890123456 is being deinitialized”
}else{
    var Appleseed: Customer? = Customer(name: "John Appleseed")
    var card: CreditCard? = CreditCard(number: 123_7675_4878_8613, customer: Appleseed!)
    Appleseed!.card = card

    let deallocCard = true
    if deallocCard {
        card = nil
        // 打印“John Appleseed is being deinitialized”
        // 打印“Card #1234567890123456 is being deinitialized”
    }else{
        Appleseed = nil
        // 打印“John Appleseed is being deinitialized”
        print("============")
        card = nil
        // 打印“Card #1234567890123456 is being deinitialized”
    }
}
```
![image.png](https://upload-images.jianshu.io/upload_images/19675505-291b99b1897a96f2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> **注意**
> 除了上述的安全的无主引用。对于需要禁用运行时的安全检查的情况（例如，出于性能方面的原因），Swift 还提供了不安全的无主引用。与所有不安全的操作一样，你需要负责检查代码以确保其安全性。 你可以通过 `unowned(unsafe) `来声明不安全无主引用。如果你试图在实例被销毁后，访问该实例的不安全无主引用，你的程序会`尝试访问该实例之前所在的内存地址`，这是一个不安全的操作。

#### 3. 无主引用和隐式解包可选属性
除了上述的两种场景，还有一种场景。
`a`、`b`两个类，`互相引用的两个属性都必须有值`，并且初始化完成后永远不会为` nil`。在这种场景中，需要一个类使用`无主属性`，而另外一个类使用`隐式解包可选值属性`。

################################
xcode新建的swift工程，缺少了main.swift文件，是因为官方对此进行了简化。如果要自行配置的话，可以去掉`AppDelegate.swift`中的`@main`。自己新建一个`main.swift`
```
import Foundation
import UIKit
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(UIApplication.self), NSStringFromClass(AppDelegate.self))
```
默认新demo是未开放查看汇编的，如果要在main.swift断点调试查看汇编的话，开启`Debug -> Debug Workflow -> always show Disassembly`就可以断在汇编代码里了。
![image.png](https://upload-images.jianshu.io/upload_images/19675505-ca2ad17780cf906a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
