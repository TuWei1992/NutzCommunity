//
//  AppSetup.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/25.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "AppSetup.h"
#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"


#define DB_NAME @"nutzcn.db"

#define SHARE_SDK_APPKEY @"f5f4a56405d0"

@implementation AppSetup

/**
 *  设置AppUI
 */
+ (void)setupUI {
    UIWindow *window = ((AppDelegate*)[UIApplication sharedApplication].delegate).window;
    window.tintColor = KCOLOR_MAIN_BLUE;
    
    // 设置Nav的背景色和title色
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    NSDictionary *textAttributes = nil;
    textAttributes = @{
                       NSFontAttributeName: [UIFont fontWithName:FONT_DEFAULE_BOLD size:NAVBAR_FONT_SIZE],
                       NSForegroundColorAttributeName: KCOLOR_MAIN_BLUE,
                       };
    
    // 后退按钮的定制在UIViewController+Swizzle里面
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    [navigationBarAppearance setTintColor:KCOLOR_MAIN_BLUE];// 返回按钮的箭头颜色
    [navigationBarAppearance setBackgroundColor:KCOLOR_CLEAR];
    [navigationBarAppearance setBarTintColor:KCOLOR_WHITE];
    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:KCOLOR_WHITE]
                                 forBarPosition:UIBarPositionTop
                                     barMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setBarStyle:UIBarStyleDefault];
    [navigationBarAppearance setShadowImage:[UIImage imageNamed:@"act_line"]];
    [navigationBarAppearance setTranslucent:YES];
    
    //不显示返回按钮标题
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -100) forBarMetrics:UIBarMetricsDefault];

    [[UITextField appearance] setTextColor:KCOLOR_MAIN_TEXT];
    [[UITextField appearance] setTintColor:KCOLOR_MAIN_TEXT];//设置UITextField的光标颜色
    [[UITextField appearance] setFont:[UIFont fontWithName:FONT_DEFAULE size:[UIFont labelFontSize]]];
    [[UITextView  appearance] setTextColor:KCOLOR_MAIN_TEXT];
    [[UITextView  appearance] setTintColor:KCOLOR_MAIN_TEXT];//设置UITextView的光标颜色
    [[UITextView  appearance] setFont:[UIFont fontWithName:FONT_DEFAULE size:[UIFont labelFontSize]]];
    //[[UIButton    appearance] setTintColor:KCOLOR_MAIN_BLUE];
    
    //badge
    [[JSBadgeView appearance] setBadgeBackgroundColor:KCOLOR_MAIN_BLUE];
    [[JSBadgeView appearance] setBadgeTextFont:[UIFont fontWithName:FONT_DEFAULE size:12]];
}

/**
 *  设置控制器路由
 */
+ (void)setupControllerRouter {
    HHRouter *router = [HHRouter shared];
    // URL Schema
    [router map:@"nutzcn://topicDetail/:topicId" toControllerClass:NSClassFromString(@"TopicDetailViewController")];
    // VCS
    [router map:@"/topicDetail/:topicId" toControllerClass:NSClassFromString(@"TopicDetailViewController")];
    [router map:@"/newTopic"             toControllerClass:NSClassFromString(@"NewTopicViewController")];
    [router map:@"/notifications"        toControllerClass:NSClassFromString(@"NotificationsViewController")];
    [router map:@"/settings"             toControllerClass:NSClassFromString(@"SettingsViewController")];
    [router map:@"/about"                toControllerClass:NSClassFromString(@"AboutViewController")];
}

/**
 *  设置启动画面
 */
+ (void)setupSplash {
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
         descriptionStr:@"Nutz社区@Nutz.cn"];
}

/**
 *  设置JPush推送
 *
 *  @param launchOptions 启动选项
 */
+ (void)setupJPush:(NSDictionary *)launchOptions {
    // 是否开启推送
    BOOL open = NO;
    NSString *val = FIND_DEFAULTS(JPUSH_ENABLE_SETTING_KEY);
    //未设置过jpush
    if(val == nil){
        open = YES;
    }else{
        if([val isEqualToString:JPUSH_ENABLE_SETTING_ON]){
            open = YES;
        }else{
            open = NO;
        }
    }

    #if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    // 去掉badge, 通知都是基于本地的, 用badge不好弄
    // iOS 8 Notifications
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                                                       (UIUserNotificationTypeSound
                                                        | UIUserNotificationTypeAlert
                                                        //|UIUserNotificationTypeBadge
                                                        ) categories:nil]];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge
                                                          | UIRemoteNotificationTypeAlert
                                                          //|UIRemoteNotificationTypeSound
                                                          )];
    }
    #endif
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge
                                                      | UIUserNotificationTypeSound
                                                      //| UIUserNotificationTypeAlert
                                                      ) categories:nil];
    
    // Required, 需要使用PushConfig.plist
    [JPUSHService setupWithOption:launchOptions];
    
    if(open){
        [self openPush:nil];
    }else{
        [self closePush:nil];
    }
   
}

+ (void)openPush:(void(^)(BOOL success))callback {
    // 注册alies, tags
    NSSet *tags = [[NSSet alloc] initWithArray:@[@"ios", FORMAT_STRING(@"ios_%@", VERSION_BUILD)]];
    NSString *alias = FORMAT_STRING(@"u_%@",[User loginedUser].ID);
    [JPUSHService setTags:tags alias:alias fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        DEBUG_LOG(@"jpush reg tagas/alias rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
        SYNC_DEFAULTS(JPUSH_ENABLE_SETTING_ON, JPUSH_ENABLE_SETTING_KEY);
        if(callback){
            callback(iResCode == 0);
        }
    }];
}

+ (void)closePush:(void(^)(BOOL success))callback {
    // 注册alies, tags
    NSSet *tags = [[NSSet alloc] initWithArray:@[@"ios", FORMAT_STRING(@"ios_%@", VERSION_BUILD)]];
    NSString *alias = @"";
    [JPUSHService setTags:tags alias:alias fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        DEBUG_LOG(@"jpush reg tagas/alias rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
        SYNC_DEFAULTS(JPUSH_ENABLE_SETTING_OFF, JPUSH_ENABLE_SETTING_KEY);
        if(callback){
            callback(iResCode == 0);
        }
    }];
}

+ (void)setupBugHD {

}

+ (void)checkUpdate {
    NSString *appId       = @" ";
    NSString *apiToken    = @" ";
    NSString *idUrlString = FORMAT_STRING(@"https://api.fir.im/apps/latest/%@?api_token=%@", appId, apiToken);

    NSURL *requestURL = [NSURL URLWithString:idUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            DEBUG_LOG(@"检查更新错误:%@", connectionError);
        }else {
            NSError *jsonError = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            DEBUG_LOG(@"检查更新成功:%@", object);
            if (!jsonError && [object isKindOfClass:[NSDictionary class]]) {
                //struct: name:string, version:string, build:string, installUrl:string, changelog:String
                if([object[@"build"] intValue] > [VERSION_BUILD intValue]){
                    NSString *title = FORMAT_STRING(@"发现新版%@.%@", object[@"version"], object[@"build"]);
                    [UIAlertView bk_showAlertViewWithTitle:title
                                                   message:object[@"changelog"]
                                         cancelButtonTitle:@"下次再说"
                                         otherButtonTitles:@[@"马上更新"]
                                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if(buttonIndex != 0){
                            //打开连接
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:object[@"update_url"]]];
                        }
                    }];
                }
            }
        }
    }];
}

/**
 *  设置应用数据库
 */
+ (void)setupDB {
    [FMDBHelper setDataBaseName:DB_NAME];
    //[JPUSHService setBadge:0];
    //[FMDBHelper createTable:@"drop table t_notification;"];
    // 建表
    NSString *sql = FORMAT_STRING(@"create table if not exists %@\
                                  (id integer primary key autoIncrement,\
                                  loginName text default '',\
                                  topicId text default '',\
                                  topicTitle text default '',\
                                  content text default '',\
                                  postUser text default '',\
                                  read boolean default false,\
                                  time text default '未知',\
                                  type integer default 0\
                                  );", [Notification tableName]);
    [FMDBHelper createTable:sql];
    DEBUG_LOG(@"total rows %ld:", [FMDBHelper totalRowOfTable:[Notification tableName]]);
}

/**
 *  设置边栏Controller
 */
+ (RESideMenu*)setupSideController {
    UIImage *bg = [[UIImage imageNamed:@"nutz2.jpg"] darkImage];
    
    MainViewController *mainController = [MainViewController  new];
    SlideViewController *slideVC       = [SlideViewController new];
    BaseNavViewController *navVC       = [[BaseNavViewController alloc] initWithRootViewController:mainController];
    RESideMenu *sideMenuVC             = [[RESideMenu alloc] initWithContentViewController:navVC
                                                              leftMenuViewController:slideVC
                                                             rightMenuViewController:nil];
    sideMenuVC.menuPrefersStatusBarHidden = YES;
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
    sideMenuVC.backgroundImage                    = bg;
    sideMenuVC.delegate                           = (id)slideVC;
    
    return sideMenuVC;
}

// 检查通知权限
+ (BOOL) isAllowedNotification {
    //iOS8 check if user allow notification
    if (IS_OS_8_OR_LATER) {// system is iOS8
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }
    } else {//iOS7
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type){
            return YES;
        }
    }
    return NO;
}

+ (void)setupShareSDK {
    [ShareSDK registerApp:SHARE_SDK_APPKEY
          activePlatforms:@[
                            @(SSDKPlatformTypeQQ),
                            @(SSDKPlatformTypeCopy)]
             onImport:^(SSDKPlatformType platformType) {
                 switch (platformType) {
                     case SSDKPlatformTypeQQ:
                         [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                         break;
                     default:
                         break;
                 }
             }
            onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                 switch (platformType) {
                         break;
                     case SSDKPlatformTypeQQ:
                         [appInfo SSDKSetupQQByAppId:@"101254640"
                                              appKey:@"d29cbc0ba12ea0b04acf2f3b8b2689ac"
                                            authType:SSDKAuthTypeBoth];
                         break;
                     default:
                         break;
                 }
             }];
}

@end
