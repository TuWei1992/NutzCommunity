//
//  APIManager.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/25.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"
#import "Topic.h"

@interface APIManager : NSObject

@property (nonatomic, strong) APIClient *client;

+ (instancetype)manager;

/**
 *  使用accessToken获得用户信息
 *
 *  @param accessToken 访问凭证
 */
- (void)userInfoByToken:(NSString *)accessToken callback:(void (^)(User* user, NSError *error))block;

- (void)userDetailInfoByName:(NSString *)userName callback:(void (^)(User* user, NSError *error))block;

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

/**
 *  发布新话题
 *
 *  @param title       标题
 *  @param tab         板块
 *  @param content     内容
 *  @param accessToken token
 *  @param block       回调
 */
- (void)newTopic:(NSString*)title tabType:(NSString*)tab content:(NSString*)content accessToken:(NSString*)accessToken callback:(void (^)(NSString* topicId, NSError *error))block;

/**
 *  回复话题
 *
 *  @param ID          话题id
 *  @param content     内容
 *  @param replyId     回复哪条内容(option)
 *  @param accessToken accessToken
 *  @param block       回调
 */
- (void)replyTopicById:(NSString*)ID content:(NSString*)content replyId:(NSString *)replyId accessToken:(NSString*)accessToken callback:(void (^)(NSString* replyId, NSError *error))block;

/**
 *  上传图片
 *
 *  @param image    上传的图片
 *  @param accessToken 登录用户访问token
 *  @param block    回调
 *  @param progress 进度
 */
- (void)uploadImage:(UIImage*)image accessToken:(NSString *)accessToken callback:(void (^)(NSString* imageUrl, NSError *error))block progerss:(void (^)(CGFloat progressValue))progress;

@end
