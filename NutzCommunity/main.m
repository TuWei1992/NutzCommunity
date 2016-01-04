                      //
//  main.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/16.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "UIViewController+Swizzle.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        swizzleAllViewController();
//        for(NSString *fontfamilyname in [UIFont familyNames])
//        {
//            NSLog(@"family:'%@'",fontfamilyname);
//            for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
//            {
//                NSLog(@"\tfont:'%@'",fontName);
//            }
//            NSLog(@"-------------");
//        }
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
