//
//  AppDelegate.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/16.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashManager.h"
#import <RESideMenu/RESideMenu.h>
#import "SlideViewController.h"
#import "TopicsViewController.h"
#import "BaseNavViewController.h"
#import "UIImage+Blur.h"
#import "UIImage+Color.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 自定义样式
    [self customizeInterface];
    // 白色状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    SlideViewController *slideVC = [[SlideViewController alloc] init];
    TopicsViewController *vc     = [[TopicsViewController alloc] init];
    BaseNavViewController *navVC = [[BaseNavViewController alloc] initWithRootViewController:vc];
    RESideMenu *sideMenuVC       = [[RESideMenu alloc] initWithContentViewController:navVC
                                                                    leftMenuViewController:slideVC
                                                                   rightMenuViewController:nil];
    sideMenuVC.parallaxEnabled                    = NO;
    sideMenuVC.bouncesHorizontally                = NO;
    sideMenuVC.scaleContentView                   = YES;
    sideMenuVC.contentViewScaleValue              = 0.94;
    sideMenuVC.scaleBackgroundImageView           = NO;
    sideMenuVC.scaleMenuView                      = NO;
    sideMenuVC.fadeMenuView                       = NO;
    sideMenuVC.contentViewShadowEnabled           = YES;
    sideMenuVC.contentViewShadowRadius            = 5.5;
    sideMenuVC.contentViewInPortraitOffsetCenterX = SIDE_MENU_CENTERX_OFFSET;
    //sideMenuVC.backgroundImage = [[UIImage imageNamed:@"nutz2.jpg"] blurredImageWithRadius:50];
    sideMenuVC.delegate                           = (id)slideVC;
    
    // Make it a root controller
    self.window.rootViewController = sideMenuVC;
    [self.window makeKeyAndVisible];
    
    [self setupLaunchImage];
    
    return YES;
}

- (void)setupLaunchImage {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"splashs" ofType:@"plist"];
    NSArray *array=[NSArray arrayWithContentsOfFile:path];
    
    int x = arc4random() % array.count;
    
    float imgWidth = SCREEN_WIDTH *2/3;
    float imgHeight = SCREEN_WIDTH/4 *2/3;
    SplashManager *sp = [SplashManager sharedInstance];
    NSString *launchImage = [sp getXCassetsLaunchImage];
    sp.iconFrame = CGRectMake((SCREEN_WIDTH - imgWidth) / 2, SCREEN_HEIGHT/7, imgWidth, imgHeight);
    [sp loadLaunchImage:array[x]
                 iconName:@"main_logo"
              appearStyle:JRApperaStyleOne
                  bgImage: launchImage
                disappear:JRDisApperaStyleOne
           descriptionStr:@"Nutz社区@nutz.cn"];
}

- (void)customizeInterface {
    // 设置Nav的背景色和title色
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    NSDictionary *textAttributes = nil;
    textAttributes = @{
                       NSFontAttributeName: [UIFont fontWithName:FONT_DEFAULE_BOLD size:NAVBAR_FONT_SIZE],
                       NSForegroundColorAttributeName: COLOR_MAIN_TEXT,
                       };
    
    // 后退按钮的定制在UIViewController+Swizzle里面
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    [navigationBarAppearance setTintColor:COLOR_MAIN_TEXT];// 返回按钮的箭头颜色
    [navigationBarAppearance setBackgroundColor:COLOR_CLEAR];
    [navigationBarAppearance setBarTintColor:COLOR_WHITE];
    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:COLOR_WHITE]
                             forBarPosition:UIBarPositionTop
                                 barMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setBarStyle:UIBarStyleDefault];
    [navigationBarAppearance setShadowImage:[UIImage new]];
    [navigationBarAppearance setTranslucent:YES];
    
    [[UITextField appearance] setTextColor:COLOR_MAIN_TEXT];
    [[UITextField appearance] setTintColor:COLOR_MAIN_TEXT];//设置UITextField的光标颜色
    [[UITextView appearance]  setTextColor:COLOR_MAIN_TEXT];
    [[UITextView appearance]  setTintColor:COLOR_MAIN_TEXT];//设置UITextView的光标颜色
    [[UIButton appearance]    setTintColor:COLOR_MAIN_TEXT];
    
    [[UITextView appearance]  setFont:[UIFont fontWithName:FONT_DEFAULE size:[UIFont labelFontSize]]];
    [[UITextField appearance] setFont:[UIFont fontWithName:FONT_DEFAULE size:[UIFont labelFontSize]]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
}

- (void)applicationWillTerminate:(UIApplication *)application {
  
}

@end
