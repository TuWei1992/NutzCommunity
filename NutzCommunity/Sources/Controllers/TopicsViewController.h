//
//  TopicsViewController.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/21.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPullRefreshViewController.h"

@interface TopicsViewController : SCPullRefreshViewController

+ (instancetype)topicsWithTabType:(NSString *)tabType;

@property (nonatomic, strong) NSString *tabType;
@property (nonatomic, strong) NSMutableArray    *topics;

@end
