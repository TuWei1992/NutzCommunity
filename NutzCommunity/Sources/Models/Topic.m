//
//  Topic.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "Topic.h"


@implementation Topic

+ (NSString *) tabType:(NSString *)engTab{
    NSDictionary *Tabs = @{
                           TAB_ASK   : @"问答",
                           TAB_NEWS  : @"新闻",
                           TAB_SHARE : @"分享",
                           TAB_NB    : @"灌水",
                           TAB_JOB   : @"招聘",
                           TAB_SHORT : @"短点"
                           };
    
    return Tabs[engTab];
}

@end
