//
//  BaseNavViewController.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "BaseNavViewController.h"

@interface BaseNavViewController ()

@end

@implementation BaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)goBack {
    [self popViewControllerAnimated:YES];
}

#pragma mark Orientations
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        return nil;
    }
    return [super popViewControllerAnimated:animated];
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        return nil;
    }
    return [super popToViewController:viewController animated:animated];
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated {
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        return nil;
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (BOOL)shouldAutorotate {
    UIViewController *topVC = [self.viewControllers lastObject];
    return [topVC shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}


@end
