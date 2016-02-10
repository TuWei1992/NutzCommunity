//
//  JDStatusBarNotification+Nutz.h
//  NutzCommunity
//
//  Created by DuWei on 16/1/19.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import <JDStatusBarNotification/JDStatusBarNotification.h>
@interface JDStatusBarNotification (Nutz)

+ (void)showStatusBarActivity:(NSString *)tip;
+ (void)showStatusBarSuccess:(NSString *)tip;
+ (void)showStatusBarErrorTip:(NSString *)tip;
+ (void)showStatusBarError:(NSError *)error;
+ (void)showStatusBarProgress:(CGFloat)progress;
+ (void)hideStatusBarProgress;

@end
