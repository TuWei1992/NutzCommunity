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
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

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
#define PHONE_MODEL    [[UIDevice currentDevice] model]

// 打印日志
#ifdef  DEBUG_OPEN
#define DEBUG_LOG(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DEBUG_LOG(s, ...)
#endif

// key window
#define KEY_WINDOW  [UIApplication sharedApplication].keyWindow
#define LAST_WINDOW [[[UIApplication sharedApplication] windows] lastObject]

// 弹窗
#define TIP_ALERT(_S_, ...)         [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__]\
                                                               delegate:nil \
                                                      cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

// 提示信息
#define TOAST_ERROR                 [MBProgressHUD showError:@"出错啦"]
#define TOAST_SHOW_WAIT             [MBProgressHUD showMessage:@"请稍后..."]
#define TOAST_SUCCESS               [MBProgressHUD showSuccess:@"成功"]
#define TOAST_INFO(_msg_)           [MBProgressHUD showInfo:_msg_]
#define TOAST_SUCCESSES(_msg_)      [MBProgressHUD showSuccess:_msg_]
#define TOAST_ERRORS(_msg_)         [MBProgressHUD showError:_msg_]
#define TOAST_SHOW_WAITS(_msg_)     [MBProgressHUD showMessage:_msg_]
#define TOAST_HIDE                  [MBProgressHUD hideHUD]
#define TOAST_HIDE_VIEW(_view_)     [MBProgressHUD hideHUDForView:_view_]

// Utils
#define FORMAT_STRING(__str_, ...)  [NSString stringWithFormat:(__str_), ##__VA_ARGS__]
#define TRIM_STRING(_str_)          [_str_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

// 将obj存进user defaults
#define SYNC_DEFAULTS(_obj_, _key_) NSUserDefaults *_key_##def = [NSUserDefaults standardUserDefaults];\
                                    [_key_##def setObject:_obj_ forKey:_key_];\
                                    [_key_##def synchronize];

#define FIND_DEFAULTS(_key_)        [[NSUserDefaults standardUserDefaults] objectForKey:_key_]

#define REMOVE_DEFAULTS(_key_)      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];\
                                    [defaults removeObjectForKey:_key_];\
                                    [defaults synchronize];\

