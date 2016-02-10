//
//  用户信息
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "BaseModel.h"
#import "Topic.h"

@interface User : BaseModel

//appsign key
#define kAppSign           FORMAT_STRING(@"app_sign_key_%@",         [User loginedUser].loginname)
#define kAppSignContent    FORMAT_STRING(@"app_sign_content_key_%@", [User loginedUser].loginname)

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString<Optional> *accessToken;
// loginname
@property (nonatomic, strong) NSString *loginname;
// avatar_url
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *githubUsername;
// create_at
@property (nonatomic, strong) NSDate   *createAt;
//相对时间
@property (nonatomic, strong) NSString *createAtForread;
@property (nonatomic, assign) int      score;
// recent_topics : Topic
@property (nonatomic, strong) NSArray<Topic> *recentTopics;
// recent_replies : Topic
@property (nonatomic, strong) NSArray<Topic> *recentReplies;

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

/**
 *  得到用户app 签名
 *
 *  @return sign
 */
+ (NSString *)userSign;
+ (BOOL)saveUserSign:(NSString *)sign;

@end
