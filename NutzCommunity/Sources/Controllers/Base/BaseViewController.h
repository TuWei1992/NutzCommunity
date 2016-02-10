//
//  BaseViewController.h
//  NutzCommunity
//
//  Created by DuWei on 16/1/15.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavViewController.h"

@interface BaseViewController : UIViewController

- (void)forceChangeToOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)push:(UIViewController*)vc;
+ (UIViewController *)presentingVC;
+ (void)presentVC:(UIViewController *)viewController;

@end
