//
//  APIManager.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/25.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"

@interface APIManager : NSObject

+ (instancetype)manager;

/**
 *  获取话题列表
 *
 *  @param tab      帖子栏目
 *  @param page     页码
 *  @param block    回调
 */
- (void)topicsByTab:(NSString *)tab
               page:(int)page
           callback:(void (^)(NSArray* topics, NSError *error))block;

/**
 *  话题详情
 *
 *  @param topicId 话题Id
 */
- (void)topicDetailById:(NSString *)topicId callback:(void (^)(Topic* topicDtail, NSError *error))block;

/**
 *  赞回复
 *
 *  @param replyId 回复id
 *  @param accessToken 登录用户访问token
 *  @param block   回调{likeType:up 点赞成功, down取消点赞成功}
 */
- (void)likeReplyById:(NSString *)replyId  accessToken:(NSString *)accessToken callback:(void (^)(NSString* likeType, NSError *error))block;

@end
