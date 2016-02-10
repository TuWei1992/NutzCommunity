//
//  帖子信息
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

@protocol Topic;

#import <Foundation/Foundation.h>
#import "SDVersion.h"
#import "Reply.h"
#import "User.h"

// 帖子板块
#define TAB_ASK     @"ask"      // 问答
#define TAB_NEWS    @"news"     // 新闻
#define TAB_SHARE   @"share"    // 分享
#define TAB_JOB     @"job"      // 工作
#define TAB_NB      @"nb"       // 灌水
#define TAB_SHORT   @"shortit"  // 短点

// 尾巴
#define TOPIC_DEFAULT_SIGN  FORMAT_STRING(@"来自 %@", stringFromDeviceVersion([SDVersion deviceVersion]))
#define TOPIC_SIGN(_sign_)  FORMAT_STRING(@"\n\n[%@](https://nutz.cn?ios_app \"app_sign\")", _sign_)

@interface Topic : BaseModel

@property (nonatomic, strong) NSString *ID;
// author_id
@property (nonatomic, strong) NSString *authorId;
@property (nonatomic, strong) User     *author;
@property (nonatomic, strong) NSString *tab;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
// last_reply_at
@property (nonatomic, strong) NSDate   *lastReplyAt;
@property (nonatomic, assign) BOOL     good;
@property (nonatomic, assign) BOOL     top;
// reply_count
@property (nonatomic, assign) int      replyCount;
// visit_count
@property (nonatomic, assign) int      visitCount;
// create_at
@property (nonatomic, strong) NSDate   *createAt;
@property (nonatomic, strong) NSArray<Reply> *replies;
// 自定义字段, 当前用户Id, 用来判断点赞
@property (nonatomic, strong) NSString *curUserId;
/**
 *  获得版块名称
 *
 *  @param engTab 板块英文
 *
 *  @return 板块中文
 */
+ (NSString *)tabTypeName:(NSString *)engTab;
+ (NSDictionary *)tabTypes;

/**
 *  保存Topic草稿
 *
 *  @param topic 话题
 */
- (void)saveTopic;

/**
 *  加载话题
 */
+ (Topic *)loadTopic;

/**
 *  删除话题草稿
 */
+ (void)delTopic;

@end
