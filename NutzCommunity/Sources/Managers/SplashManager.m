//
//  启动画面管理
//  SplashManager.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/22.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "SplashManager.h"


#ifndef SCREEN_BOUNDS
#define SCREEN_BOUNDS ([UIScreen mainScreen].bounds)
#endif
#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#endif
#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#endif

#define APPEAR_TIME 0.7
#define DISAPPEAR_TIME 0.6

#define DISAPPERAED_STATUS_BAR_STYLE UIStatusBarStyleDefault

@interface SplashManager()

@end

@implementation SplashManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static SplashManager *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[SplashManager alloc] init];
    });
    return sharedInstance;
}

- (void)loadLaunchImage:(NSString *)imageName {
    
    // 0. keyWindow
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 1. 遮罩 View
    _dumy = [[UIView alloc] initWithFrame:SCREEN_BOUNDS];
    _dumy.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:APPEAR_TIME animations:^{
        _dumy.alpha = 0;
    } completion:^(BOOL finished) {
        [_dumy removeFromSuperview];
    }];
    
    _launchimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    _launchimage.frame = SCREEN_BOUNDS;
    
    
    [window addSubview:_launchimage];
    [window addSubview:_dumy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(13 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self imageDismiss];
    });
}

- (void)imageDismiss {
    [self.launchimage removeFromSuperview];
}

- (void)loadLaunchImage:(NSString *)imageName iconName:(NSString *)icon{
    
    // 0. keyWindow
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 1. 背景图
    _dumy = [[UIView alloc] initWithFrame:SCREEN_BOUNDS];
    _dumy.backgroundColor = [UIColor blackColor];
    
    // 2.
    _bgImage = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
    _bgImage.image = [UIImage imageNamed:imageName];
    _bgImage.alpha = 0.0;
    
    [UIView animateWithDuration:APPEAR_TIME animations:^{
        _bgImage.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    // 3. icon
    _iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_coding_top"]];
    _iconImage.frame = CGRectMake((SCREEN_WIDTH - 213) * 0.5, 80, 213, 54);
    [window addSubview:_dumy];
    [window addSubview:_bgImage];
    [window addSubview:_iconImage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissAll:JRDisApperaStyleLeft];
    });
}

- (void)imageDismiss2 {
    [self.dumy removeFromSuperview];
    [self.bgImage removeFromSuperview];
    [self.iconImage removeFromSuperview];
}

- (void)loadLaunchImage:(NSString *)imgName
               iconName:(NSString*)iconName
            appearStyle:(JRApperaStyle)style
                bgImage:(NSString *)bgName
              disappear:(JRDisApperaStyle)disappear
         descriptionStr:(NSString *)des {
    
    // 1. 背景
    if (bgName.length != 0) {
        self.bgImage = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        self.bgImage.image = [UIImage imageNamed:bgName];
    }
    
    // 2. 加载图
    if (imgName.length != 0) {
        self.launchimage = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        //self.launchimage.contentMode = UIViewContentModeScaleAspectFit;
        self.launchimage.image = [UIImage imageNamed:imgName];
    }
    
    // 3. icon
    if (iconName.length != 0) {
        self.iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
        self.iconImage.frame = self.iconFrame;
    }
    
    // 4. label
    if (des.length != 0) {
        self.desLabel = [[UILabel alloc] init];
        self.desLabel.textAlignment = NSTextAlignmentCenter;
        if(self.desLabel.frame.size.width != 0){
            self.desLabel.frame = self.desLabelFreme;
        }else{
            self.desLabel.frame = CGRectMake(0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 25);
        }
        
        self.desLabel.text = des;
        self.desLabel.layer.shadowOpacity = 0.8;
        self.desLabel.layer.shadowColor = KCOLOR_BLACK.CGColor;
        self.desLabel.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        self.desLabel.font = [UIFont fontWithName:FONT_DEFAULE_BOLD size:12];
        self.desLabel.textColor = [UIColor whiteColor];
        [self.launchimage addSubview:_desLabel];
    }
    
    [self appera:style disappear:disappear];
}


- (void)appera:(JRApperaStyle)style disappear:(JRDisApperaStyle)disappear{
    
    // 0. keywindow
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (style == JRApperaStyleNone) {
        [window addSubview:_bgImage];
        [window addSubview:_launchimage];
        [window addSubview:_iconImage];
    } else if (style == JRApperaStyleOne) {
        
        [window addSubview:_bgImage];
        [window addSubview:_launchimage];
        [window addSubview:_iconImage];
        _launchimage.alpha = 0.0;
        
        [UIView animateWithDuration:APPEAR_TIME animations:^{
            _launchimage.alpha = 1.0;
        } completion:^(BOOL finished) {
            //消失
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissAll:disappear];
            });
        }];
    }
    
}

- (void)dismissAll:(JRDisApperaStyle)style {
    
    if (style == JRDisApperaStyleOne) {
        
        _bgImage.alpha = 0.0f;
        [UIView animateWithDuration:DISAPPEAR_TIME
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _iconImage.alpha = 0.0f;
                             _launchimage.alpha = 0.0f;
                             _launchimage.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1);
                         }
                         completion:^(BOOL finished) {
                             [_bgImage removeFromSuperview];
                             [_launchimage removeFromSuperview];
                             [_iconImage removeFromSuperview];
                             //设置状态栏
                             [[UIApplication sharedApplication] setStatusBarStyle:DISAPPERAED_STATUS_BAR_STYLE];
                         }];
        
        return;
    } else if (style == JRDisApperaStyleTwo) {
        _bgImage.alpha = 0.0f;
        [UIView animateWithDuration:DISAPPEAR_TIME
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _iconImage.alpha = 0.0f;
                             _launchimage.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [_bgImage removeFromSuperview];
                             [_launchimage removeFromSuperview];
                             [_iconImage removeFromSuperview];
                             //设置状态栏
                             [[UIApplication sharedApplication] setStatusBarStyle:DISAPPERAED_STATUS_BAR_STYLE];
                         }];
        return;
    } else if (style == JRDisApperaStyleLeft) {
        
        _bgImage.alpha = 0.0;
        [UIView animateWithDuration:DISAPPEAR_TIME
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _iconImage.alpha = 0.0f;
                             _launchimage.alpha = 0.0f;
                             CGRect frame = _launchimage.frame;
                             frame.origin.x = -SCREEN_WIDTH;
                             _launchimage.frame = frame;
                             
                             frame = _iconImage.frame;
                             frame.origin.x = -SCREEN_WIDTH;
                             _iconImage.frame = frame;
                             
                             frame = _bgImage.frame;
                             frame.origin.x = -SCREEN_WIDTH;
                             _bgImage.frame = frame;
                             
                             frame = _desLabel.frame;
                             frame.origin.x = -SCREEN_WIDTH;
                             _desLabel.frame = frame;
                             
                             frame = _dumy.frame;
                             frame.origin.x = -SCREEN_WIDTH;
                             _dumy.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [_bgImage removeFromSuperview];
                             [_launchimage removeFromSuperview];
                             [_iconImage removeFromSuperview];
                             [_desLabel removeFromSuperview];
                             
                             [_dumy removeFromSuperview];

                             //设置状态栏
                             [[UIApplication sharedApplication] setStatusBarStyle:DISAPPERAED_STATUS_BAR_STYLE];
                         }];
        return;
    } else if (style == JRDisApperaStyleRight) {
        
        [UIView animateWithDuration:DISAPPEAR_TIME
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _iconImage.alpha = 0.0f;
                             _launchimage.alpha = 0.0f;
                             CGRect frame = _launchimage.frame;
                             frame.origin.x += SCREEN_WIDTH;
                             _launchimage.frame = frame;
                             
                             frame = _iconImage.frame;
                             frame.origin.x += SCREEN_WIDTH;
                             _iconImage.frame = frame;
                             
                             frame = _bgImage.frame;
                             frame.origin.x += SCREEN_WIDTH;
                             _bgImage.frame = frame;
                             
                             frame = _desLabel.frame;
                             frame.origin.x += SCREEN_WIDTH;
                             _desLabel.frame = frame;
                             
                             frame = _dumy.frame;
                             frame.origin.x += SCREEN_WIDTH;
                             _dumy.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [_bgImage removeFromSuperview];
                             [_launchimage removeFromSuperview];
                             [_iconImage removeFromSuperview];
                             [_desLabel removeFromSuperview];
                             
                             [_dumy removeFromSuperview];
                             
                             //设置状态栏
                             [[UIApplication sharedApplication] setStatusBarStyle:DISAPPERAED_STATUS_BAR_STYLE];
                         }];
        return;
    } else if (style == JRDisApperaStyleBottom) {
        
        [UIView animateWithDuration:DISAPPEAR_TIME
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _iconImage.alpha = 0.0f;
                             _launchimage.alpha = 0.0f;
                             CGRect frame = _launchimage.frame;
                             frame.origin.y += SCREEN_HEIGHT;
                             _launchimage.frame = frame;
                             
                             frame = _iconImage.frame;
                             frame.origin.y += SCREEN_HEIGHT;
                             _iconImage.frame = frame;
                             
                             frame = _bgImage.frame;
                             frame.origin.y += SCREEN_HEIGHT;
                             _bgImage.frame = frame;
                             
                             frame = _desLabel.frame;
                             frame.origin.y += SCREEN_HEIGHT;
                             _desLabel.frame = frame;
                             
                             frame = _dumy.frame;
                             frame.origin.y += SCREEN_HEIGHT;
                             _dumy.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [_bgImage removeFromSuperview];
                             [_launchimage removeFromSuperview];
                             [_iconImage removeFromSuperview];
                             [_desLabel removeFromSuperview];
                             
                             [_dumy removeFromSuperview];
                             //设置状态栏
                             [[UIApplication sharedApplication] setStatusBarStyle:DISAPPERAED_STATUS_BAR_STYLE];
                         }];
        return;
    } else if (style == JRDisApperaStyleTop) {
        
        [UIView animateWithDuration:DISAPPEAR_TIME
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _iconImage.alpha = 0.0f;
                             _launchimage.alpha = 0.0f;
                             CGRect frame = _launchimage.frame;
                             frame.origin.y = -SCREEN_HEIGHT;
                             _launchimage.frame = frame;
                             
                             frame = _iconImage.frame;
                             frame.origin.y = -SCREEN_HEIGHT;
                             _iconImage.frame = frame;
                             
                             frame = _bgImage.frame;
                             frame.origin.y = -SCREEN_HEIGHT;
                             _bgImage.frame = frame;
                             
                             frame = _desLabel.frame;
                             frame.origin.y = -SCREEN_HEIGHT;
                             _desLabel.frame = frame;
                             
                             frame = _dumy.frame;
                             frame.origin.y = -SCREEN_HEIGHT;
                             _dumy.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [_bgImage removeFromSuperview];
                             [_launchimage removeFromSuperview];
                             [_iconImage removeFromSuperview];
                             [_desLabel removeFromSuperview];
                             
                             [_dumy removeFromSuperview];
                             
                             //设置状态栏
                             [[UIApplication sharedApplication] setStatusBarStyle:DISAPPERAED_STATUS_BAR_STYLE];
                         }];
        return;
    }
    
    [_desLabel removeFromSuperview];
    [_bgImage removeFromSuperview];
    [_launchimage removeFromSuperview];
    [_iconImage removeFromSuperview];
}


- (NSString *)getXCassetsLaunchImage {
    
    NSDictionary * dict = @{@"320x480" : @"LaunchImage-700", @"320x568" : @"LaunchImage-700-568h", @"375x667" : @"LaunchImage-800-667h", @"414x736" : @"LaunchImage-800-Portrait-736h"};
    
    NSString * key = [NSString stringWithFormat:@"%dx%d", (int)[UIScreen mainScreen].bounds.size.width, (int)[UIScreen mainScreen].bounds.size.height];
    
    //UIImage * launchImage = [UIImage imageNamed:dict[key]];
    return dict[key];
}

@end
