//
//  app 配置辅助类
//  AppSetup.h
//  NutzCommunity
//
//  Created by DuWei on 16/1/25.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SplashManager.h"
#import <LGSideMenuController/LGSideMenuController.h>
#import <RESideMenu/RESideMenu.h>
#import "MainViewController.h"
#import "SlideViewController.h"
#import "BaseNavViewController.h"
#import "JPUSHService.h"
#import "UIImage+Blur.h"
#import "UIImage+Color.h"
#import "Notification.h"
#import <JSBadgeView/JSBadgeView.h>

@interface AppSetup : NSObject

/**
 *  设置AppUI
 */
+ (void)setupUI;

/**
 *  设置控制器路由
 */
+ (void)setupControllerRouter;

/**
 *  设置启动画面
 */
+ (void)setupSplash;

/**
 *  设置JPush推送
 *
 *  @param launchOptions 启动选项
 */
+ (void)setupJPush:(NSDictionary *)launchOptions;

/**
 *  打开推送
 */
+ (void)openPush:(void(^)(BOOL success))callback;

/**
 *  关闭推送
 */
+ (void)closePush:(void(^)(BOOL success))callback;

/**
 *  崩溃日志
 */
+ (void)setupBugHD ;

/**
 *  检查更新
 */
+ (void)checkUpdate;

/**
 *  设置应用数据库
 */
+ (void)setupDB;

/**
 *  设置边栏Controller
 */
+ (UIViewController*)setupSideController;

/**
 *  检查是否有通知权限
 */
+ (BOOL) isAllowedNotification;

/**
 *  分享
 */
+ (void)setupShareSDK;

@end
