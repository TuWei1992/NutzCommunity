//
//  SysUtils.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/22.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define IS_IPHONE4S ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
                        ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) \
                        : NO)
#define IS_IPHONE5S ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
                        ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) \
                        : NO)
#define IS_IPHONE6  ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
                        ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) \
                        : NO)
#define IS_IPHONE6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] \
                        ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) \
                        : NO)

#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width


// 版本号
#define VERSION_STRING [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define VERSION_BUILD  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#define APP_IDENTIFIER [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define IOS_VERSION    [NSString stringWithFormat:@"%@ %@", \
                            [UIDevice currentDevice].systemName, \
                            [UIDevice currentDevice].systemVersion]

// 打印日志
#ifdef DEBUG_OPEN
#define DEBUG_LOG(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DEBUG_LOG(s, ...)
#endif

// key window
#define KEY_WINDOW [UIApplication sharedApplication].keyWindow

// 弹窗
#define kTipAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

