## 定义与调用
#### 1.普通样式
 `->`  来指定函数返回值类型
```
func greet(person: String, day: String) -> String{
    return "hello \(person), today is \(day)"
}
greet(person: "Bob", day: "Tuesday")
//"hello Bob, today is Tuesday"
```
####  2.忽略参数
```_``` 表示方法该参数，使用时不需要引入参数标签
```
func greet2(_ person: String, on day: String) -> String{
    return "hello \(person), today is \(day)"
}
greet2("Tino", on: "Wednesday")
//"hello Tino, today is Wednesday"

// 所有参数都不引入标签
func greet3(_ person: String, _ day: String) -> String{
    return "hello \(person), today is \(day)"
}
greet3("Xiaoming", "Wednesday")
//"hello Xiaoming, today is Wednesday"
```
#### 3.默认参数值
```
func greet4(_ person: String = "Xiaoming", _ day: String = "Wednesday") -> String{
    return "hello \(person), today is \(day)"
}
greet4()
//"hello Xiaoming, today is Wednesday"
```
#### 4.可变参数函数
一个函数最多只能拥有一个可变参数。
```
func greet5(_ persons: String...) -> String{
    var sayHello = ""
    for person in persons {
        sayHello = sayHello + "hello \(person) \n"
    }
    return sayHello
}
print(greet5("laoda","laoer","laosan","laosi","laowu","laoliu"))
/**
 hello laoda
 hello laoer
 hello laosan
 hello laosi
 hello laowu
 hello laoliu
 */
```
#### 5.输入输出参数（```inout```修饰）
不能有默认值，而且可变参数不能用 ```inout``` 标记。
```
func swapTwoInts(_ a: inout Int , _ b: inout Int){
    let tmp = a
    a = b
    b = tmp
}
var someInt = 3
var anotherInt = 107
swapTwoInts(&someInt, &anotherInt)
print("someInt is \(someInt), anotherInt is \(anotherInt)")
//someInt is 107, anotherInt is 3
```
## 函数类型
结合元组
```
// 1. 返回值为元组
func calculate(_ scores:[Int]) -> (max:Int , min:Int , total:Int , pass: Int){
    guard scores.count > 0 else {
        return (0,0,0,0)
    }
    var min = scores[0]
    var max = scores[0]
    var total = 0
    var pass = 0

    for score in scores {
        if score > max {
            max = score
        }
        if score < min {
            min = score
        }
        total += score
        if score > 60 {
            pass += 1
        }
    }
    return (max,min,total,pass)
}
print(calculate([10,20,70,80,55,39,100,65]))
//(max: 100, min: 10, total: 439, pass: 4)

// 2. 返回值为可选元组
func minMax(array: [Int]) -> (min: Int, max: Int)? {
    if array.isEmpty { return nil }
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}

// 元组只能针对少量元素，超过6个以后各种运算会报错
var user1 = (name:"Bill", sex: true, age: 18, top: 180, weight:180 , hairColor: "yello", score: 80)
var user2 = (name:"Bill", sex: true, age: 18, top: 180, weight:180 , hairColor: "yello", score: 80)
//user1 == user2
//Binary operator '==' cannot be applied to two '(name: String, sex: Bool, age: Int, top: Int, weight: Int, hairColor: String, score: Int)' operands

// 3. 参数为元组
func transformModelToDict(_ x:(name: String, sex: Bool, age: Int)) -> [String: Any]{
    var dict:[String:Any] = [:]
    dict["name"] = x.name
    dict["sex"] = x.sex
    dict["age"] = x.age
    return dict
}
print(transformModelToDict((name: "yes", sex: true, age: 18)))
//["age": 18, "name": "yes", "sex": true]

let mirror = Mirror(reflecting: user1)
for (subLabel, value) in mirror.children {
    let label = String(describing: subLabel)
    switch value {
    case is Int:
        print("type is Int, label is \(label), value is \(value)")
    case is Bool:
        print("type is Bool, label is \(label), value is \(value)")
    case is String:
        print("type is String, label is \(label), value is \(value)")
    default:
        print("type isDefault, label is \(label), value is \(value)")
    }
}

// 4. 隐式返回的函数 省略return
func greeting(for person: String) -> String {
    "Hello, " + person + "!"
}
print(greeting(for: "Dave"))
// 打印 "Hello, Dave!"
```

## 函数嵌套
1. 常规用法
```
func returnFifteen() -> Int{
    func returnFive() -> Int{
        return 5
    }
    func returnTen() -> Int{
        return returnFive() + returnFive()
    }
    return returnFive() + returnTen()
}
print(returnFifteen()) //15
// 或者这样用
func chooseFuncToUse(isadd: Bool) -> (Int) -> Int{
    func func1(input:Int) -> Int {input + 1}
    func func2(input:Int) -> Int {input - 1}
    return isadd ? func1 : func2
}
var tmp = 3
let theFunc = chooseFuncToUse(isadd: tmp < 0)
while tmp > 0{
    print("tmp is \(tmp)")
    tmp = theFunc(tmp)
}
/**
tmp is 3
tmp is 2
tmp is 1
*/
```
2. 函数作为变量
```
var myfunc :() -> Int = returnFifteen // myfunc == returnFifteen
func oneFunc(_ a: Int, _ b: Int) -> Int{
    return a + b
}
var myfunc2 :(Int,Int) -> Int = oneFunc(_:_:) // myfunc2 == oneFunc
```
3. 函数作为返回值，返回的是函数 (Int)->Int
```
func makeAdd() ->(Int) -> Int{
    func addOne(_ number: Int) -> Int{
        return number + 1
    }
    // 完整调用的写法  addOne(_:) ，下边是简写
    return addOne
}
let theAddOneFunc = makeAdd()//返回的是addOne(_:)函数
print(theAddOneFunc(2))//3
```
4. 函数作为参数
```
func hasAnyMatches(list: [Int], condition: (Int) -> Bool) -> Bool{
    for item in list {
        if condition(item) {
            return true
        }
    }
    return false
}
let numbers = [20,19,7,12]
func lessThanTen(_ number: Int) -> Bool{
    if number < 10 {
        return true
    }
    return false
}
print(hasAnyMatches(list: numbers, condition: lessThanTen))//true
print(numbers.sorted())//[7, 12, 19, 20]
print(numbers.sorted{$0 > $1}) // [20, 19, 12, 7]
```
## 闭包 
用```{}```直接包起一个函数，```in```分割，前部为```参数```、```返回值```，后部为```函数实现```
* ```$``` 操作符是代指遍历每一项元素
* ```$0``` 就是函数传入的第一个参数，```$1``` 就是第二个，以此类推...
```
// 简写
/// 闭包实际上是对函数的简化，下边的函数都是相同的结果，数组每项元素x10
let arrayOfInt = [2,3,4,5,4,7,2]
arrayOfInt.map({(someInt: Int) -> Int in return someInt * 10 })
arrayOfInt.map({(someInt: Int) in return someInt * 10 })
arrayOfInt.map({someInt in return someInt * 10 })
arrayOfInt.map({someInt in someInt * 10 })
arrayOfInt.map({$0 * 10 })
arrayOfInt.map{$0 * 10 }
```
```
// 整体*3
var newNumbers = numbers.map({
    (number: Int) -> Int in
    let result = 3 * number
    return result
})
// 判断奇偶
var checkResult = {(number : Int) -> (Int) in
    let result = number % 2
    if result == 1 {
        return 0
    }
    return number
}

print("numbers is \(numbers)")//"numbers is [20, 19, 7, 12]"
print("newNumbers is \(newNumbers)")//"newNumbers is [60, 57, 21, 36]"
```

##  高阶函数
#### 1. map函数
```func map(transform: (T) -> U) -> [U]```
> 接受一个闭包作为规则，自动遍历集合的每一个元素，使用闭包的规则去处理这些元素，生成一个结构相同的集合

map使用
```
let cast = ["Vivien", "Marlon", "Kim", "Karl"]
let lowerCast = cast.map({$0.lowercased()})
print(lowerCast)//"["vivien", "marlon", "kim", "karl"]"
let castCount = cast.map({$0.count})
print(castCount)//"[6, 6, 3, 4]"
print(cast.map{"名字是 ：\($0)"})//["名字是 ：Vivien", "名字是 ：Marlon", "名字是 ：Kim", "名字是 ：Karl"]
let mappedNumbers = numbers.map({ number in 3 * number })
print(mappedNumbers)//[60, 57, 21, 36]
```
##### flatMap
> 接受一个闭包作为规则，自动遍历集合的每一个元素，使用闭包的规则去处理这些元素，将处理结果直接放入到一个新的集合里面，可以出现```数组降维```，并且会自动过滤```nil```(```自动解包```)，如果是不包含nil元素的一维数组的和map的作用效果是一样的，所以推荐使用```flatMap```

map对象为数组时，将numbers数组的每个元素强制转换为```{}```内规则的类型，并按每一项拆分，生成一个新的一维数组
```
let numbers = [20,19,7,12]

/// 1.传入字符串： 强转String数组，将每一项与"的"字符拼接，按字符逐项拆分
let flatMapResult = numbers.flatMap({"\($0)的"})
//["2", "0", "的", "1", "9", "的", "7", "的", "1", "2", "的"]

/// 2.传入字符串数组：强转String数组，将参数数组每一项与原数组（现字符串数组）拼接，生成新的一维数组
let flatMapResult2 = numbers.flatMap({["\($0)的","他叫\($0)"]})
//["20的", "他叫20", "19的", "他叫19", "7的", "他叫7", "12的", "他叫12"]

/// 3.传入数字运算操作：numbers.flatMap({$0+1})系统警告，需用compactMap替换
// 数字运算操作时，需用compactMap替换flatMap
let compactMapResult = numbers.compactMap({$0+1})
//[21, 20, 8, 13]

/// compactMap会过滤掉不符合闭包规则的值，看下边的官方demo
let possibleNumbers = ["1", "2", "three", "///4///", "5"]

// map声明变量时Int类型必须带？
let mapped: [Int?] = possibleNumbers.map { str in Int(str) }
// [Optional(1), Optional(2), nil, nil, Optional(5)]

// compactMap声明变量时Int类型可以带，也可以不带
let compactMapped: [Int] = possibleNumbers.compactMap { str in Int(str) }
// Int类型时，会过滤nil，结果[1, 2, 5]
// Int？类型时，不会过滤nil，结果[Optional(1), Optional(2), nil, nil, Optional(5)]

/// 4.传入字典操作：将原数组每一个元素都变为一个字典
let flatMapResult3 = numbers.flatMap({["\($0)":"他叫\($0)"]})
//[(key: "20", value: "他叫20"), (key: "19", value: "他叫19"), (key: "7", value: "他叫7"), (key: "12", value: "他叫12")]

/// 5.数组降维操作，一次flatMap操作只能降低一层维度
let numbers2 = [[[1,2,3],[4,5,6],[7,8,9]],[10,11,12]]
let flatMapResult4 = numbers2.flatMap({$0})
//[[1, 2, 3], [4, 5, 6], [7, 8, 9], 10, 11, 12]
```
map对象为字典时
```
let dict = ["1":"4","2":"5","3":"6"]
let flatMapDictResult:[Int] = dict.compactMap({Int($1)})
// [6, 5, 4]
let flatMapDictResult2 = dict.map{(key,value) in key.capitalized}
//["1", "2", "3"]
```

###### 应用：
举例，从一个model数组内，获取一个uid是否存在
```
let model1 = (uid:111,index:1)
let model2 = (uid:222,index:2)
let model3 = (uid:333,index:3)
let models = [model1,model2,model3]
// 原先方法
func checkUidExist(_ uid: Int) -> Bool{
    for model in models {
        if model.uid == uid {
           return true
        }
    }
    return false
}
// map方法
func checkUidExist2(_ uid: Int) -> Bool{
    let uids = models.map({$0.uid})
    return uids.contains(uid)
}
var startTime = CFAbsoluteTimeGetCurrent()
print(checkUidExist(000))//false
print("checkUidExist 代码执行时长：\((CFAbsoluteTimeGetCurrent() - startTime)*1000) 毫秒")
//checkUidExist 代码执行时长：0.43392181396484375 毫秒

startTime = CFAbsoluteTimeGetCurrent()
print(checkUidExist2(000))//false
print("checkUidExist2 代码执行时长：\((CFAbsoluteTimeGetCurrent() - startTime)*1000) 毫秒")
//checkUidExist2 代码执行时长：0.2570152282714844 毫秒
````

##### 2. filter函数
```func filter(includeElement: (T) -> Bool) -> [T]```
> 接受一个闭包作为筛选规则，自动遍历集合的每一个元素，保留符合闭包规则的元素，生成一个```新的集合```

耗时对比
```
/// 下边是一个取奇数数组的例子
func newListOfOddLevel(_ array: [Int]) -> [Int] {
    var newList = [Int]()
    for item in array {
        if item % 2 == 1 {
            newList.append(item)
        }
    }
    return newList
}
let arrayOfIntegers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
/// 常规操作
startTime = CFAbsoluteTimeGetCurrent()
print(newListOfOddLevel(arrayOfIntegers)) // [1, 3, 5, 7, 9]
print("newListOfOddLevel 代码执行时长：\((CFAbsoluteTimeGetCurrent() - startTime)*1000) 毫秒")
// newListOfOddLevel 代码执行时长：0.5530118942260742 毫秒

// filter函数
startTime = CFAbsoluteTimeGetCurrent()
let filterResult1 = arrayOfIntegers.filter {$0%2 == 1}
print(filterResult1) // [1, 3, 5, 7, 9]
print("filter 代码执行时长：\((CFAbsoluteTimeGetCurrent() - startTime)*1000) 毫秒")
// filter 代码执行时长：0.28502941131591797 毫秒
```

##### 3. reduce函数
```func reduce(initial: U, combine: (U, T) -> U) -> U```
>接受一个初始化值，并且接受一个闭包作为规则，自动遍历集合的每一个元素，使用闭包的规则去处理这些元素，合并处理结果,返回结果是```一个值```
```Returns the result of combining the elements of the sequence using the given closure```（重点在于```combining```）

可以简单理解成累加器，累积操作
```
// 数字串
let arrayOfFloat = [2.0, 3.0, 4.0, 5.0, 7.0]
let total = arrayOfFloat.reduce(0, +) // 21
// 字符串
let arrayOfString = ["abc","def","ghi"]
let totalString = arrayOfString.reduce("", +) // abcdefghi

// 输出新串
let customStr = arrayOfString.reduce("111") { (Result, arrayOfString) in
    "\(Result) , \(arrayOfString)"
}
print(customStr) // 111 , abc , def , ghi

let packages = [
    (name: "Swift高阶函数编程", number: 1, price: 80.0, address: "来广营"),
    (name: "Swift面向协议编程", number: 2, price: 88.0, address: "西二旗"),
    (name: "Swift基础", number: 3, price: 35.0, address: "798"),
    (name: "Swift进阶", number: 4, price: 50.0, address: "中关村")
]

let reduceName = packages.reduce("/") {$0 + $1.name}
print(reduceName) 
// Swift高阶函数编程Swift面向协议编程Swift基础Swift进阶
```
耗时对比
```
func sum(_ initialResult : Int, _ array : [Int]) -> Int {
    var result = initialResult
    for item in array {
        result += item
    }
    return result
}
startTime = CFAbsoluteTimeGetCurrent()
print(sum(10, arrayOfInt))// 37
print("sum 代码执行时长：\((CFAbsoluteTimeGetCurrent() - startTime)*1000) 毫秒")
// sum 代码执行时长：0.29206275939941406 毫秒 

startTime = CFAbsoluteTimeGetCurrent()
print(arrayOfInt.reduce(10, +)) // 37
print("reduce 代码执行时长：\((CFAbsoluteTimeGetCurrent() - startTime)*1000) 毫秒")
// reduce 代码执行时长：0.04494190216064453 毫秒
```

