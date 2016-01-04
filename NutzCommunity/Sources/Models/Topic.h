//
//  帖子信息
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Reply.h"

// 帖子板块
#define TAB_ASK     @"ask"      // 问答
#define TAB_NEWS    @"news"     // 新闻
#define TAB_SHARE   @"share"    // 分享
#define TAB_JOB     @"job"      // 工作
#define TAB_NB      @"nb"       // 灌水
#define TAB_SHORT   @"shortit"  // 短点

@interface Topic : BaseModel

@property (nonatomic, strong) NSString *id;
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

/**
 *  获得版块名称
 *
 *  @param engTab 板块英文
 *
 *  @return 板块中文
 */
+ (NSString *)tabType:(NSString *)engTab;

@end
