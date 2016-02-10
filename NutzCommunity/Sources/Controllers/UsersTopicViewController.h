//
//  UsersTopicViewController.h
//  NutzCommunity
//
//  Created by DuWei on 16/2/5.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "BaseViewController.h"

@interface UsersTopicViewController : BaseViewController

+ (instancetype)usersTopicWithTopics:(NSArray *)topics;
- (void)reloaData:(NSArray *)topics;

@end
