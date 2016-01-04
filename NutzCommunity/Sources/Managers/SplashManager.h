//
//  SplashManager.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/22.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JRApperaStyle) {
    JRApperaStyleNone,
    JRApperaStyleOne,
};

typedef NS_ENUM(NSUInteger, JRDisApperaStyle) {
    JRDisApperaStyleNone,
    JRDisApperaStyleOne,
    JRDisApperaStyleTwo,
    JRDisApperaStyleLeft,
    JRDisApperaStyleRight,
    JRDisApperaStyleBottom,
    JRDisApperaStyleTop,
};

#import <Foundation/Foundation.h>

@interface SplashManager : NSObject


@property (nonatomic, strong) UIImageView	*bgImage;
@property (nonatomic, strong) UIImageView	*iconImage;
@property (nonatomic, strong) UIImageView	*launchimage;
@property (nonatomic, strong) UIView		*dumy;

@property (nonatomic, assign) CGRect  iconFrame;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, assign) CGRect  desLabelFreme;

+ (instancetype)sharedInstance;
- (void)loadLaunchImage:(NSString *)imageName;
- (void)loadLaunchImage:(NSString *)imageName iconName:(NSString *)icon;

/**
 *  加载启动画面
 *  首先需要设置项目默认的launch 图片, 然后在AppDelegate中加载此方法
 *
 *  @param imgName   背景图片名称
 *  @param iconName  上方显示的logo
 *  @param style     显示方式
 *  @param bgName    默认Launch图片名称
 *  @param disappear 隐藏方式
 *  @param des       底部描述文字
 */
- (void)loadLaunchImage:(NSString *)imgName
               iconName:(NSString*)iconName
            appearStyle:(JRApperaStyle)style
                bgImage:(NSString *)bgName
              disappear:(JRDisApperaStyle)disappear
         descriptionStr:(NSString *)des;

- (NSString *)getXCassetsLaunchImage;
@end
