//
//  用户信息
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface User : BaseModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString<Optional> *accessToken;
// loginname
@property (nonatomic, strong) NSString *loginname;
// avatar_url
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *githubUsername;
// create_at
@property (nonatomic, strong) NSDate   *createAt;
@property (nonatomic, assign) int      score;
// recent_topics : Topic
@property (nonatomic, strong) NSArray  *recentTopics;
// recent_replies : Topic
@property (nonatomic, strong) NSArray  *recentReplies;

/**
 *  返回当前登录的用户,nil代表未登录
 *
 *  @return user/nil
 */
+ (User *)loginedUser;

/**
 *  保存用户
 *
 *  @param user 用户信息
 *
 */
+ (void)saveUser:(User *)user;

/**
 *  退出登录
 */
+ (void)logout;

@end
