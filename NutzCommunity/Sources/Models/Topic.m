//
//  Topic.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "Topic.h"

#define TOPIC_DEFAULTS_KEY @"_topic_key"

@implementation Topic

static NSDictionary *tabTypes;

+ (NSString *) tabTypeName:(NSString *)engTab{
    return [self tabTypes][engTab];
}

+ (NSDictionary *)tabTypes{
    if(!tabTypes){
      tabTypes = @{
             TAB_NB    : @"灌水",
             TAB_SHARE : @"分享",
             TAB_NEWS  : @"新闻",
             TAB_ASK   : @"问答",
             TAB_SHORT : @"短点",
             TAB_JOB   : @"招聘"
        };
    }
    return tabTypes;
}

- (void)saveTopic {
    SYNC_DEFAULTS([self toDictionary], TOPIC_DEFAULT_SIGN);
}

+ (Topic *)loadTopic {
    return [[Topic alloc] initWithDictionary: FIND_DEFAULTS(TOPIC_DEFAULT_SIGN)];
}

+ (void)delTopic {
    REMOVE_DEFAULTS(TOPIC_DEFAULT_SIGN);
}

@end
