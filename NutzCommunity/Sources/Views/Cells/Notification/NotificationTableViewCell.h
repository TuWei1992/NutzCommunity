//
//  NotificationTableViewCell.h
//  NutzCommunity
//
//  Created by DuWei on 16/1/26.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic ) IBOutlet UIButton     *loginName;
@property (weak, nonatomic ) IBOutlet UILabel      *content;
@property (weak, nonatomic ) IBOutlet UILabel      *time;
@property (weak, nonatomic) IBOutlet UILabel *topicTitle;

// 通知模型
@property (strong,nonatomic) NSDictionary          *notification;

@end
