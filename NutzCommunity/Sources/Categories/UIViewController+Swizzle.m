//
//  UIViewController+Swizzle.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/23.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import "ObjcRuntime.h"

@implementation UIViewController (Swizzle)

- (void)customViewDidLoad {
    // 返回按钮
    if (!self.navigationItem.backBarButtonItem
        && self.navigationController.viewControllers.count > 1) {
        //设置返回按钮(backBarButtonItem的图片不能设置；如果用leftBarButtonItem属性，则iOS7自带的滑动返回功能会失效)
        self.navigationItem.leftBarButtonItem = [self backButton];
    }
    
    [self customViewDidLoad];
}

- (void)customViewDidAppear:(BOOL)animated {
    
    [self customViewDidAppear:animated];
}

- (void)customViewWillDisappear:(BOOL)animated {
    
    [self customViewWillDisappear:animated];
}

- (void)customviewWillAppear:(BOOL)animated {
    
    [self customviewWillAppear:animated];
}


#pragma mark BackBtn M
- (UIBarButtonItem *)backButton {
    
    //定制后退按钮
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackSwizzle)];
    backBtn.title = @"";
    
    return backBtn;
}

- (void)goBackSwizzle {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

void swizzleAllViewController() {
    Swizzle([UIViewController class], @selector(viewDidLoad),     @selector(customViewDidLoad));
    Swizzle([UIViewController class], @selector(viewDidAppear:),     @selector(customViewDidAppear:));
    Swizzle([UIViewController class], @selector(viewWillDisappear:), @selector(customViewWillDisappear:));
    Swizzle([UIViewController class], @selector(viewWillAppear:),    @selector(customviewWillAppear:));
}
