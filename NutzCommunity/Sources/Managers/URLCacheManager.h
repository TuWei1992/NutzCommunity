//
//  URLCacheManager.h
//  NutzCommunity
//
//  Created by DuWei on 16/2/7.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLCacheManager : NSURLCache
+ (instancetype)sharedCache;
@end
