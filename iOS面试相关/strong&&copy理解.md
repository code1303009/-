*copy和strong 区别*

NSString、NSArray、NSDictionary不可变变量修饰问题，以NSString为例
全局属性
```
@property (nonatomic , strong) NSString *strongstr;
@property (nonatomic , copy) NSString *copystr;
```

**情况1：**
```
/**
*   situation 1
*   不可变初始化，全局变量赋值
*   因为是全局变量直接赋值，不会调用setter方法，所以这里strong和copy都不生效
*/
NSString *str1 = [NSString stringWithFormat:@"hello"];
_strongstr = str1;
_copystr = str1;
NSLog(@"       对象地址          对象指针地址       对象的值   ");
NSLog(@"str1 == %p, &str1 == %p, str1 == %@",str1,&str1,str1);
NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
```
输出：
```
str1 == 0xdc0dbcf13f739f90, &str1 == 0x7ffee59628b8, str1 == hello
strongstr == 0xdc0dbcf13f739f90, &strongstr == 0x7fe3a8c1d570, strongstr == hello
copystr == 0xdc0dbcf13f739f90, &copystr == 0x7fe3a8c1d578, copystr == hello

```

**情况2**
```
/**
*  situation 2
*  NSString子类NSMutableString进行赋值，依旧全局变量进行赋值
*  因为是全局变量直接赋值，即使指向的是可变变量NSMutableString并且调用局部变量的setter方法，但依旧不会调用全局变量的setter方法，所以这里strong和copy依旧不生效
*/
NSMutableString *str2 = [[NSMutableString alloc] initWithString:@"hello2"];
_strongstr = str2;
_copystr = str2;
[str2 setString:@"what2"];
NSLog(@"       对象地址          对象指针地址       对象的值   ");
NSLog(@"str2 == %p, &str2 == %p, str2 == %@",str2,&str2,str2);
NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
```
输出：
```
str2 == 0x6000026ec8a0, &str2 == 0x7ffee59628b0, str2 == what2
strongstr == 0x6000026ec8a0, &strongstr == 0x7fe3a8c1d570, strongstr == what2
copystr == 0x6000026ec8a0, &copystr == 0x7fe3a8c1d578, copystr == what2
```

**情况3**
```
/**
*  situation 3
*  NSString子类NSMutableString进行赋值，改用self.指针进行赋值
*  strong的setter只是进行了retain操作，引用计数+1，对象地址指向str3地址，str3变值也会相应变值
*  copy的setter会对str3进行[str3 copy]深拷贝操作，重新生成了新对象，str3变值不会影响copy对象
*/
NSMutableString *str3 = [[NSMutableString alloc] initWithString:@"hello3"];
self.strongstr = str3;
self.copystr = str3;

[str3 setString:@"what3"];
NSLog(@"       对象地址          对象指针地址       对象的值   ");
NSLog(@"str3 == %p, &str3 == %p, str3 == %@",str3,&str3,str3);
NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
```
输出：
```
str3 == 0x6000026e4000, &str3 == 0x7ffee59628a8, str3 == what3
strongstr == 0x6000026e4000, &strongstr == 0x7fe3a8c1d570, strongstr == what3
copystr == 0xdc0e8cf13f739f93, &copystr == 0x7fe3a8c1d578, copystr == hello3
```

**情况4**
```
/**
*  situation 4
*  不可变类型NSString进行赋值，改用self.指针进行赋值
*  因为是不可变类型，这里copy就只是浅拷贝，没有新生成对象，只是拷贝了指针
*/
NSString *str4 = [NSString stringWithFormat:@"hello4"];
self.strongstr = str4;
self.copystr = str4;
NSLog(@"       对象地址          对象指针地址       对象的值   ");
NSLog(@"str4 == %p, &str4 == %p, str4 == %@",str4,&str4,str4);
NSLog(@"strongstr == %p, &strongstr == %p, strongstr == %@",_strongstr,&_strongstr,_strongstr);
NSLog(@"copystr == %p, &copystr == %p, copystr == %@",_copystr,&_copystr,_copystr);
```
输出：
```
str4 == 0xdc0efcf13f739f93, &str4 == 0x7ffee59628a0, str4 == hello4
strongstr == 0xdc0efcf13f739f93, &strongstr == 0x7fe3a8c1d570, strongstr == hello4
copystr == 0xdc0efcf13f739f93, &copystr == 0x7fe3a8c1d578, copystr == hello4
```

**总结**
*当原字符串是NSString时，由于是不可变字符串，所以，不管使用strong还是copy修饰，都是指向原来的对象，copy操作只是做了一次浅拷贝。
*而当源字符串是NSMutableString时，strong只是将源字符串的引用计数加1，而copy则是对原字符串做了次深拷贝，从而生成了一个新的对象，并且copy的对象指向这个新对象。另外需要注意的是，这个copy属性对象的类型始终是NSString，而不是NSMutableString，如果想让拷贝过来的对象是可变的，就要使用mutableCopy。

但是，我们一般声明NSString时，也不希望它改变，所以一般情况下，建议使用copy，这样可以避免NSMutableString带来的错误。



**顺便路过提一下assign与weak**
我们都知道，weak是用来修饰oc对象，assign是用来修饰基本数据类型

按原理讲，assign也可以用来修饰oc对象，但是有个问题，oc对象释放后，assign修饰的对象指针还存在，会造成**野指针**问题造成crach。
但是weak用来修饰的话，在对象释放的时候，指针也会相应的置为nil，避免了野指针问题。

至于为什么assign可以用来修饰基本数据类型，因为系统的基本数据类型是存放在栈内的。栈内部都是系统自己管理分配和释放的，不会有野指针问题
