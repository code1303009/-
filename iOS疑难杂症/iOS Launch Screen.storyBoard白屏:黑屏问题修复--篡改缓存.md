# **需求**
弃用LaunchImage启动图方式，改用Launch Screen.storyBoard启动图方式，同时不对开屏广告造成影响。
### **注：该方案仅适用iOS13.0及以上版本。**
iOS 12及以下系统沙盒目录（Library/Caches/Snapshots）为不可读、不可写、可删除（但是开发者无权删除）权限，故本套方案不起作用。

# **背景**
现阶段网上流行的storyboard开屏：
1. 开屏图片从主目录读取，一张图适配所有界面。首先这种方式是不存在缓存的，实时取肯定是准确的图。但是作为业务方，这种满足不了自定义的四季样式，还会存在拉伸。
2. 图片存在XCAsset中，每次使用完，都会删除沙盒目录(Library/SplashBoard)文件，虽然有版本限制，但是大概率存在黑/白屏风险，也是不达标。

### **PS：该文方案都是以xcasset缓存开屏为基础的，首次storyboard替换LuanchImage，且未做沙盒缓存清空的，参考[文章](https://www.jianshu.com/p/2b916b5e1fb2)。如果之前对沙盒有操作的，可能会有异常。**

Apple会将Launch Screen.storyBoard作为与图片类型类似的二进制文件，进行加载，执行是在main函数之前，所以不参与业务代码控制。适配就不做多余的阐述了。

# **一、问题**

在iOS应用程序中修改了启动屏幕LaunchScreen.storyboad中的某些内容时，我都会遇到一个问题：系统会缓存启动图像，即使删除了该应用程序，它实际上也很难清除原来的缓存，猜测会有多级缓存。

# **二、分析**

我们可以改动的缓存只有本地的沙盒目录（/Library/SplashBoard的Snapshots），打印的日志：
```
2020-05-19 09:25:38.138233+0800 luanchTest[3892:1751265] cache Path == /var/mobile/Containers/Data/Application/BCA1FD18-2A24-43A9-B844-65A5D38A5B9D/Library/SplashBoard,subpath == (
    Snapshots,
    "Snapshots/wei.jiang.luanchTest - {DEFAULT GROUP}",
    "Snapshots/wei.jiang.luanchTest - {DEFAULT GROUP}/B6C097B0-5F66-4740-A20A-5FBDAA2EE484@2x.ktx",
    "Snapshots/wei.jiang.luanchTest - {DEFAULT GROUP}/83BE4383-44CF-41E0-9E3F-235E6D132B61@2x.ktx",
    "Snapshots/wei.jiang.luanchTest - {DEFAULT GROUP}/D2761A77-E07C-4D3B-9551-C90F643218BF@2x.ktx",
    "Snapshots/wei.jiang.luanchTest - {DEFAULT GROUP}/A3E1D437-7876-481C-A5AA-4940E69770A6@2x.ktx",
    "Snapshots/sceneID:wei.jiang.luanchTest-default",
    "Snapshots/sceneID:wei.jiang.luanchTest-default/1970FB13-BDA2-44F0-B998-ECFEDE1068A6@2x.ktx",
    "Snapshots/sceneID:wei.jiang.luanchTest-default/2890B753-D9F5-4030-881A-FA35EF24D922@2x.ktx",
    "Snapshots/sceneID:wei.jiang.luanchTest-default/downscaled",
    "Snapshots/sceneID:wei.jiang.luanchTest-default/downscaled/BBF126DF-765D-4607-A052-02CA0426DAA5@2x.ktx",
    "Snapshots/sceneID:wei.jiang.luanchTest-default/downscaled/4E66BDD7-D46C-4F16-917F-BE23E8E0F1B9@2x.ktx"
)
```
一目了然，Snapshots就是我们操作的文件夹，将ktx导出转换后缀，可以看到就是我们要的启动图，因为我这里是用的多个模拟器所以会有多张，正常的会只有一张。

**注：如果项目工程是以xcode11方式新建的话，就需要处理UIScene的截图，我们的项目没有用到UIScene方式，所以没有做相应处理。**

# **三、解决**
#####思路：推测系统在沙盒目录有图的时候，会从沙盒拿图。所以我们在保持原有目录的情况下，只做图片内容的替换（有坑，有同事之前一直用的主目录方式&&有过沙盒目录的删除操作，替换到这种方式每次首次读图都会空白屏）。

##### **1.取图：**

每次展示自定义启动页时，优先从Snapshots里拿image进行展示（无图是从storyBoard拿图），进行无缝衔接；

##### **2.替换：**

当次展示完启动图时，进行更新（**将storyBoard的image同步到Snapshots**）。避免重复无用操作做了版本控制。

不多说了，直接上代码吧。
```
/*
 * 配套Launch Screen.storyBoard的启动加载方式
 */
@interface MJLaunchScreenTool : NSObject

/*
*  获取沙盒/SplashBoard/Snapshots目录下的启动图（推荐）
*  自定义开屏推荐用此方法拿取启动图
*/
+ (UIImage *)getCacheLaunchImageByLirbrary;

/*
 *  获取Launch Screen.storyBoard内对应的Asset适配的启动图
 */
+ (UIImage *)getLaunchImageByStoreBoard;

/*
 * 更替修正storyboard的缓存启动图（storyboard作启动图的情况下，不可删除）
 */
+ (void)updateSplashBoardCache:(BOOL)fetImageFromStoryBoard;
/**
 * 更新是否首次安装标志位
*/
+ (void)updateCoverFisrtInstall:(BOOL)isFirst;

@end
```

```
#import "MJLaunchScreenTool.h"

#define kSplashBoard_Version @"kSplashBoard_Version"
#define kSplashBoardCoverInstallFirst @"kSplashBoard_Type_CoverInstall_first"
#define kMJSplashBoardCopyImageName @"mj_cover_install_first_image.png"
@implementation MJLaunchScreenTool

//从storyboard获取启动图
+ (UIImage *)getLaunchImageByStoreBoard{
    UIImage *launchImage = nil;
    UIStoryboard *launchScreenStoryBoard = [UIStoryboard storyboardWithName:@"Launch Screen" bundle:[NSBundle mainBundle]];
    UIView *view = [launchScreenStoryBoard.instantiateInitialViewController view];
    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:UIImageView.class]){//开屏imageview
            launchImage = [(UIImageView *)v image];
            break;
        }
    }
    return launchImage;
}

//从沙盒获取启动图
+ (UIImage *)getCacheLaunchImageByLirbrary{
    if (![self isAvailable]) {
        return [self getLaunchImageByStoreBoard];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isCoverFirst = [userDefault boolForKey:kSplashBoardCoverInstallFirst];
    NSString *cacheLaunchPath = nil;
    if (isCoverFirst) {
        cacheLaunchPath = [NSString stringWithFormat:@"%@/%@",[self getCoverInstallFirstImagePath],kMJSplashBoardCopyImageName];
    }else{
        cacheLaunchPath = [[self getCacheLaunchImageArrayPath] firstObject];
    }
    return [[UIImage alloc] initWithContentsOfFile:cacheLaunchPath];
}

#pragma mark - launch screen.storyBoard 缓存清理、重置（版本更新时需调用）
//部分机型可能出现缓存同时用到2张截图的情况
//所以在不改动系统原有缓存数的情况下 仅做替换 防止出错
+ (void)updateSplashBoardCache:(BOOL)fetImageFromStoryBoard{
    if (![self isAvailable]) {
        NSString *cache = [NSString stringWithFormat:@"%@/Library/Caches/Snapshots/",NSHomeDirectory()];
        NSLog(@"Library/Caches/Snapshots 是否为可写目录 ： %d",[[NSFileManager defaultManager] isWritableFileAtPath:cache]);
        NSLog(@"Library/Caches/Snapshots 是否为可读目录 ： %d",[[NSFileManager defaultManager] isReadableFileAtPath:cache]);
        NSLog(@"Library/Caches/Snapshots 是否为可删除目录 ： %d",[[NSFileManager defaultManager] isDeletableFileAtPath:cache]);
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *splashVersion = [userDefault objectForKey:kSplashBoard_Version];
    NSLog(@"进入了storyboard开屏清理方法");
    // APP_VERSION为外部定义的版本号 也可以是bundleVersion
    if (![splashVersion isEqualToString:APP_VERSION] || !splashVersion) {//非当前版本都会更新截图
        //更新系统截图
        UIImage *launchImage = nil;
        if (fetImageFromStoryBoard) {
            launchImage = [self getLaunchImageByStoreBoard];
        }else{
            //xcasset 内配置的图片组
            launchImage = [UIImage imageNamed:@"LaunchStoryBoardImages"];
        }
        NSArray *cacheLauchPaths = [self getCacheLaunchImageArrayPath];
        NSData *imageData = UIImagePNGRepresentation(launchImage);
        if (launchImage && cacheLauchPaths.count > 0) {
            for (NSString *path in cacheLauchPaths) {
                if (![imageData writeToFile:path atomically:YES]) {
                    NSLog(@"storyBoard方式启动图，写入缓存失败");
                }else{
                    NSLog(@"storyBoard方式启动图，写入缓存成功，files == %@",[[NSFileManager defaultManager] subpathsAtPath:[self splashShotCachePath]]);
                    // 更新标志位
                    [userDefault setObject:MOJI_VERSION forKey:kSplashBoard_Version];
                    [userDefault synchronize];
                }
            }
        }
    }
}

+ (void)updateCoverFisrtInstall:(BOOL)isFirst{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL cacheValue = [userDefault boolForKey:kSplashBoardCoverInstallFirst];
    if (cacheValue == isFirst) {
        return;
    }
    [userDefault setBool:isFirst forKey:kSplashBoardCoverInstallFirst];
    [userDefault synchronize];
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *copyDirectoryPath = [self getCoverInstallFirstImagePath];
    BOOL isDir = false;
    BOOL isDirExist = [defaultManager fileExistsAtPath:copyDirectoryPath
                                        isDirectory:&isDir];
    if (!isDirExist || !isDir) {
        [defaultManager createDirectoryAtPath:copyDirectoryPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil];
    }
    NSString *copyFullPath = [NSString stringWithFormat:@"%@/%@",copyDirectoryPath,kMJSplashBoardCopyImageName];
    if (isFirst) {
        NSArray *array = [self getCacheLaunchImageArrayPath];
        NSLog(@"storyboard->storyboard方式，开屏截屏缓存数组：%@",array);
        if (array.count > 0) {
            NSString *cacheLaunchPath = [array firstObject];
            NSError *error = nil;
            if ([defaultManager fileExistsAtPath:cacheLaunchPath]){
                BOOL success = [defaultManager copyItemAtPath:cacheLaunchPath toPath:copyFullPath error:&error];
                if (success) {
                    NSLog(@"storyboard->storyboard方式，首次覆盖安装，图片备份成功");
                }else{
                    NSLog(@"storyboard->storyboard方式，首次覆盖安装，图片备份失败，文件是否存在%d，copyPath == %@,error == %@",[defaultManager fileExistsAtPath:cacheLaunchPath],copyFullPath,error);
                }
            }
        }
    }else{
        NSLog(@"storyboard->storyboard方式，移除首次覆盖安装缓存图片");
        if ([defaultManager fileExistsAtPath:copyFullPath]) {
            [defaultManager removeItemAtPath:copyFullPath error:nil];
        }
    }
}

#pragma mark - 路径
+ (NSString *)splashShotCachePath{
    NSString *snapShotPath = nil;
    if ([UIDevice currentDevice].systemVersion.floatValue < 13.0) {
        snapShotPath = [NSString stringWithFormat:@"%@/Library/Caches/Snapshots/%@/",NSHomeDirectory(),[NSBundle mainBundle].bundleIdentifier];
    }else{
        //13.0以上系统
        snapShotPath = [NSString stringWithFormat:@"%@/Library/SplashBoard/Snapshots/%@ - {DEFAULT GROUP}/",NSHomeDirectory(),[NSBundle mainBundle].bundleIdentifier];
    }
    return snapShotPath;
}

// 获取缓存的启动图路径多图数组
+ (NSArray *)getCacheLaunchImageArrayPath{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    //splashBoard的缓存截图路径
    NSString * snapShotPath = [self splashShotCachePath];
    NSLog(@"library splashBoard path == %@, subFiles == %@",snapShotPath,[defaultManager subpathsAtPath:snapShotPath]);
    
    NSArray *snapShots = [defaultManager subpathsAtPath:snapShotPath];
    NSMutableArray *shotArray = [NSMutableArray array];
    for (NSString *shotNameStr in snapShots) {
        if ([shotNameStr hasSuffix:@".ktx"]) {
            //完整路径数组
            [shotArray addObject: [NSString stringWithFormat:@"%@%@",snapShotPath,shotNameStr]];
        }
        //历史截图清空
//        [defaultManager removeItemAtPath:shotNameStr error:nil];
    }
    
    if (shotArray.count > 0) {
        return shotArray;
    }
    return nil;
}

#pragma mark - 备份路径（业务需求）
+ (NSString *)getCoverInstallFirstImagePath{
    NSString *mjSnapShotPath = [NSString stringWithFormat:@"%@/Library/MJSplashBoard",NSHomeDirectory()];
    return mjSnapShotPath;
}

+ (BOOL)isAvailable{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) {
        return YES;
    }
    return NO;
}
@end
```

# **四、用法**
# **用法**
#### **1. 版本更新逻辑(覆盖安装+首次安装置yes)**
```
 if ([curMojiVesion isEqualToString:MOJI_VERSION]) {
     coverFirstInstall = NO;
     [MJLaunchScreenTool updateCoverFisrtInstall:NO];
 } else {
     coverFirstInstall = YES;
     [MJLaunchScreenTool updateCoverFisrtInstall:YES];
 }
```

#### **2. 占位图调用逻辑**
```
  //placeholder
  UIImage *image = [MJLaunchScreenTool getCacheLaunchImageByLirbrary];
  if (!image) {
      image = [MJLaunchScreenTool getLaunchImageByStoreBoard];
  }
  _launchImageView.image = image;
```
#### **3. 更新缓存（启动图结束使用之后，调用）**
```
[MJLaunchScreenTool updateSplashBoardCache:NO];
```
# **附：我们app开屏流程**
1. 系统storyBoard
2. 自有开屏占位图
3. 自有开屏图片展示
4. 删除自定义开屏

更新缓存是在**步骤4**进行操作的。

# **2020.06.04更新**
测试中，我们发现现有的开屏流程存在问题。
# **问题**
在首次覆盖安装后，当次的热启动开屏会出现，新老开屏闪变的问题。
流程1阶段的时候，展示的是旧的开屏占位图；
流程2阶段的时候，展示的是新的开屏占位图；
就出现了：
**旧占位图==>新占位图==>开屏广告图片==>开屏小时的情况**
# **猜想**
1. 系统覆盖安装时，由于上一个版本，系统沙盒（Library/SplashBoard）缓存了开屏。覆盖安装后，沙盒缓存还是上一次的开屏图片；启动时，系统依旧从沙盒拿取上一次开屏，加载到内存，作为当次开屏占位图。
2. 但是杀死app后，系统重新从沙盒（Library/SplashBoard）拿图，加载到内存，这时候沙盒图片已经被我们更新。相当于清理了缓存，相当于更新了storyboard开屏占位图。
# **思考**
我们可以换个思路考虑，这个问题仅仅在 **“首次覆盖安装”** ，而且 **“同为storyboard方式作为开屏方式”** 的时候才会出现。
那我们是不是可以针对 **首次覆盖安装** + **两次皆为storyboard方式作为开屏** 的情况做单独处理呢？
# **思路**
#### **1. 首次覆盖安装的情况特殊处理：**
版本号不一致时，本次会copy系统沙盒（Library/SplashBoard）开屏图至自定义沙盒路径(我这里定义的是Library/JWSplashBoard)备份，且当次开屏占位图为该备份图，在备份完之后，更新系统沙盒开屏图片（删除旧图，添加新图）。
#### **2. 非首次启动时，默认之前处理方式**
每次取系统沙盒路径，并删除备份占位图（Library/JWSplashBoard路径下）。


#--------------------------完结撒花-----------------------
![](https://upload-images.jianshu.io/upload_images/19675505-46391978692c2395.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


适配参考：[iOS13---LaunchScreen.storyboard 启动图屏幕适配「一」](https://www.jianshu.com/p/2b916b5e1fb2)

附：[demo]([https://github.com/code1303009/learning-recording/blob/master/iOS%E7%96%91%E9%9A%BE%E6%9D%82%E7%97%87/MJLaunchScreenTool.m)
