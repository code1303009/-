//
//  MJLaunchScreenTool.h
//  MojiWeather
//
//  Created by wei.jiang on 2020/5/14.
//  Copyright © 2020 Moji Fengyun Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 * 配套Launch Screen.storyBoard的启动加载方式
 */
@interface MJLaunchScreenTool : NSObject

/*
*  获取沙盒/SplashBoard/Snapshots目录下的启动图（推荐）
*  自定义开屏推荐用此方法拿取启动图
*/
+ (UIView *)getCacheLaunchImageByLirbrary;

/*
 *  获取Launch Screen.storyBoard内对应的Asset适配的启动图
 */
+ (UIView *)getLaunchImageByStoreBoard;

/*
 * 更替修正storyboard的缓存启动图（storyboard作启动图的情况下，不可删除）
 */
+ (void)updateSplashBoardCache:(BOOL)fetImageFromStoryBoard;
/**
 * 更新是否首次安装标志位
*/
+ (void)updateCoverFisrtInstall:(BOOL)isFirst;

@end

NS_ASSUME_NONNULL_END
