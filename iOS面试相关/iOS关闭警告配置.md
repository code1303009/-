# iOS 关闭警告配置

object-c中经常出现一些弃用方法或者方法未找到警告，去掉这些警告可以用 **#pragma clang diagnostic** 宏定义

```
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-相关命令"
// 警告代码块
// ...
#pragma clang diagnostic pop
```

## 方法弃用警告
```
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// 警告代码块
// ...
#pragma clang diagnostic pop
```

## 不兼容指针类型警告
```
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
// 警告代码块
// ...
#pragma clang diagnostic pop
```

## 未使用变量警告
```
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
// 警告代码块
// ...
#pragma clang diagnostic pop
```

## 循环引用警告
```
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
// 警告代码块
// ...
#pragma clang diagnostic pop
```

## 对象弱引用警告
```
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreceiver-is-weak"
// 警告代码块
// ...
#pragma clang diagnostic pop
```

## GUN编译警告
```
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
// 警告代码块
// ...
#pragma clang diagnostic pop
```

## nullable和nonull警告
```
NS_ASSUME_NONNULL_BEGIN
@interface UserModel<ObjectType> : NSObject

@property(nonatomic,strong,nullable) ObjectType object;
- (void)pushObject:(ObjectType)object;

@end

NS_ASSUME_NONNULL_END
```
