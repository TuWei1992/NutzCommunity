//
//  Notification.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/26.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "Notification.h"

@implementation Notification

+ (Notification *)handlerNotification:(NSDictionary*)notification {
    // 取得自定义字段内容
    NSString *topicId    = [notification valueForKey:@"topic_id"];
    NSString *postUser   = [notification valueForKey:@"post_user"];
    NSString *topicTitle = [notification valueForKey:@"topic_title"];

    // 取得 APNs 标准信息内容
    NSDictionary *aps = [notification valueForKey:@"aps"];

    Notification *notify = [Notification new];
    notify.topicId       = topicId;
    notify.postUser      = postUser;
    notify.topicTitle    = topicTitle;
    notify.content       = [aps valueForKey:@"alert"];
    notify.type          = [[notification valueForKey:@"type"] intValue];
    notify.loginName     = [User loginedUser].loginname;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    notify.time                = [formatter stringFromDate:[NSDate date]];
    
    return notify;
}

+ (NSInteger)save:(Notification *)notification {
    //将通知存进数据库, 这fmdbhelper玩意,太难用了...
    [FMDBHelper insertObject:notification];
    [self notifyChange];
    // 查询刚刚插入的
    NSDictionary *lastNotify = [[FMDBHelper query:[Notification tableName]
                                            where:@"id=(select max(id) from t_notification)", nil] lastObject];
    return [lastNotify[@"id"] integerValue];
}

+ (void)updateReadById:(int)notificationId {
    // 标为已读
    [FMDBHelper update:[Notification tableName]
             keyValues:@{@"read":@(YES)}
                 where:FORMAT_STRING(@"id=%d", notificationId)];
    [self notifyChange];
}

+ (void)updateAllRead {
    NSString *condation = FORMAT_STRING(@"loginName='%@'",[User loginedUser].loginname);
    [FMDBHelper update:FORMAT_STRING(@"update %@ set read=1 where %@;", [Notification tableName], condation)];
    // 通知
    [self notifyChange];
}

+ (NSArray *)queryAllUnRead {
    // 查询某个用户的未读通知
    NSString *condation = FORMAT_STRING(@"read = 0 and loginName='%@'",[User loginedUser].loginname);
    NSArray *dbNotifis  = [FMDBHelper query:[Notification tableName] where:condation, nil];
    return dbNotifis;
}

+ (NSArray *)queryAll {
    // 查询某个用户的所有通知
    NSString *condation = FORMAT_STRING(@"loginName='%@'",[User loginedUser].loginname);
    NSArray *dbNotifis  = [FMDBHelper query:[Notification tableName] where:condation, nil];
    return dbNotifis;
}

+ (void)deleteById:(int)notificationId {
    [FMDBHelper removeById:FORMAT_STRING(@"%d", notificationId) from:[Notification tableName]];
    [self notifyChange];
}

// 发送"通知"变化的通知
+ (void)notifyChange {
    //NSArray *notifis = [self queryAllUnRead];
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_NOTIFICATION_UPDATE
                                                        object:nil
                                                      userInfo:@{@"unreads":@""}];
}

+ (NSString *)tableName {
    return @"t_notification";
}

@end
