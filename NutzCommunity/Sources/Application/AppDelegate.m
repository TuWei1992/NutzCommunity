//
//  AppDelegate.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/16.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "AppDelegate.h"
#import "AppSetup.h"
#import "URLCacheManager.h"

@interface AppDelegate (){
    // 点击通知启动的app
    BOOL bootFromNotification;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [AppSetup setupDB];
    // JPush通知
    [AppSetup setupJPush:launchOptions];
    // 自定义样式
    [AppSetup setupUI];
    // 注册VC路由
    [AppSetup setupControllerRouter];
    // 白色状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // 滑动侧栏
    [self.window setRootViewController:[AppSetup setupSideController]];
    [self.window makeKeyAndVisible];
    // 启动画面
    [AppSetup setupSplash];
    //处理通知
    if(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]){
        bootFromNotification = YES;
    }
    //分享
    [AppSetup setupShareSDK];
    //检查更新
    //[AppSetup checkUpdate];

    //放弃本地缓存WebView图片的策略
    //[NSURLCache setSharedURLCache:[URLCacheManager sharedCache]];
    
    return YES;
}


#pragma mark 通知相关
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    DEBUG_LOG(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    DEBUG_LOG(@"收到Push消息: %@ \n state: %ld",userInfo, application.applicationState);
    
    // Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
   
    // 处理通知
    Notification *notify = [Notification handlerNotification:userInfo];
    NSInteger nId        = [Notification save:notify];
    
    // 从通知栏启动
    if(bootFromNotification || application.applicationState == UIApplicationStateInactive){
        // 重置状态
        bootFromNotification = NO;
        [self presentController:notify.topicId];
        //更新为已读
        [Notification updateReadById:(int)nId];
        
    }else{
        // alert 提示
        [UIAlertView bk_showAlertViewWithTitle:notify.content message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"查看"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            //查看话题
            if(buttonIndex != 0){
                [self presentController:notify.topicId];
                //更新为已读
                [Notification updateReadById:(int)nId];
            }
        }];
    }
}
#endif

- (void)presentController:(NSString *)topicId {
    //跳转到主题视图
    UINavigationController *vc = (UINavigationController*)((RESideMenu*)self.window.rootViewController).contentViewController;
    [vc pushViewController:HHROUTER(FORMAT_STRING(@"/topicDetail/%@", topicId)) animated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //NSArray *notifis = [Notification queryAllUnRead];
    //[[UIApplication sharedApplication]  setApplicationIconBadgeNumber:notifis.count];
    //[JPUSHService setBadge:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //app角标
    //NSArray *notifis = [Notification queryAllUnRead];
    //[[UIApplication sharedApplication]  setApplicationIconBadgeNumber:notifis.count];
    //[JPUSHService setBadge:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
