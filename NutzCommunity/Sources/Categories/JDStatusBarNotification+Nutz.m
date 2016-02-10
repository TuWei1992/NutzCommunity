//
//  JDStatusBarNotification+Nutz.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/19.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "JDStatusBarNotification+Nutz.h"

@implementation JDStatusBarNotification (Nutz)

#pragma mark notifications
+ (void)showStatusBarActivity:(NSString *)tipStr{
    [JDStatusBarNotification showWithStatus:tipStr styleName:JDStatusBarStyleDefault];
    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
}
+ (void)showStatusBarSuccess:(NSString *)tipStr{
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.0 styleName:JDStatusBarStyleSuccess];
    }
}
+ (void)showStatusBarErrorTip:(NSString *)tip {
    [JDStatusBarNotification showWithStatus:tip dismissAfter:1.5 styleName:JDStatusBarStyleError];
}
+ (void)showStatusBarError:(NSError *)error{
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:[self tipFromError:error] dismissAfter:1.5 styleName:JDStatusBarStyleError];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:[self tipFromError:error] dismissAfter:1.5 styleName:JDStatusBarStyleError];
    }
}
+ (void)showStatusBarProgress:(CGFloat)progress{
    [JDStatusBarNotification showProgress:progress];
    
}
+ (void)hideStatusBarProgress{
    [JDStatusBarNotification showProgress:0.0];
}

+ (NSString *)tipFromError:(NSError *)error {
    if (error && error.userInfo) {
        NSMutableString *tipStr = [[NSMutableString alloc] init];
        if ([error.userInfo objectForKey:@"message"]) {
            NSArray *msgArray = [[error.userInfo objectForKey:@"message"] allValues];
            NSUInteger num = [msgArray count];
            for (int i = 0; i < num; i++) {
                NSString *msgStr = [msgArray objectAtIndex:i];
                if (i+1 < num) {
                    [tipStr appendString:[NSString stringWithFormat:@"%@\n", msgStr]];
                }else{
                    [tipStr appendString:msgStr];
                }
            }
        }else{
            if ([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
                tipStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }else{
                [tipStr appendFormat:@"错误码%ld", (long)error.code];
            }
        }
        return tipStr;
    }
    return nil;
}

@end
