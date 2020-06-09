//
//  MJLaunchScreenTool.m
//  MojiWeather
//
//  Created by wei.jiang on 2020/5/14.
//  Copyright © 2020 Moji Fengyun Technology Co., Ltd. All rights reserved.
//

#import "MJLaunchScreenTool.h"
#import "UIView+ScreenShot.h"

#define kSplashBoard_Version @"kSplashBoard_Version"
#define kSplashBoardCoverInstallFirst @"kSplashBoard_Type_CoverInstall_first"
#define kMJSplashBoardCopyImageName @"mj_cover_install_first_image.png"
@implementation MJLaunchScreenTool

//从storyboard获取启动图
+ (UIView *)getLaunchImageByStoreBoard{
    UIStoryboard *launchScreenStoryBoard = [UIStoryboard storyboardWithName:@"Launch Screen" bundle:[NSBundle mainBundle]];
    UIView *view = [launchScreenStoryBoard.instantiateInitialViewController view];
    return view;
}

//从沙盒获取启动图
+ (UIView *)getCacheLaunchImageByLirbrary{
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
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:cacheLaunchPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = SCREEN_FRAME;
    return imageView;
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
            UIView *launchView = [self getLaunchImageByStoreBoard];
            launchImage = [launchView screenShot];
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
