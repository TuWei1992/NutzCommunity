//
//  社区通知
//  Notification.h
//  NutzCommunity
//
//  Created by DuWei on 16/1/26.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "BaseModel.h"
#import <FMDBHelper/FMDBHelper.h>

#define KEY_UNREAD @"unread_notifis"

typedef enum{
    NotificationTypeReply = 0,
    NotificationTypeAt
} NotificationType;

@interface Notification : BaseModel
// 用户名, 用于筛查
@property (strong, nonatomic) NSString *loginName;
// 主题Id
@property (strong, nonatomic) NSString *topicId;
// 主题标题
@property (strong, nonatomic) NSString *topicTitle;
// 通知内容
@property (strong, nonatomic) NSString *content;
// 相关用户
@property (strong, nonatomic) NSString *postUser;
// 类型 NotificationType
@property (assign, nonatomic) int      type;
// 是否已读
@property (assign, nonatomic) BOOL     read;
// 通知时间
@property (strong, nonatomic) NSString *time;

/**
 *  处理jpush通知
 *
 *  @param notification jpush消息
 *
 *  @return notification
 */
+ (Notification *)handlerNotification:(NSDictionary*)notification;

/**
 *  保存通知到数据库
 *
 *  @param notification 通知
 *
 *  @return 保存后通知的id
 */
+ (NSInteger)save:(Notification *)notification;

/**
 *  将通知标记为已读
 */
+ (void)updateReadById:(int)notificationId;

/**
 *  将所有通知标记为已读
 */
+ (void)updateAllRead;

/**
 *  查询当前用户所有未读通知
 */
+ (NSArray *)queryAllUnRead;

/**
 *  查询当前用户所有通知
 */
+ (NSArray *)queryAll;

/**
 *  根据id删除通知
 *
 *  @param notificationId 通知id
 */
+ (void)deleteById:(int)notificationId;

+ (NSString *)tableName;

@end
