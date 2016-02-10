//
//  NotificationTableViewCell.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/26.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setupViews];
}

- (void)setupViews {
    [self.loginName.titleLabel setFont:[UIFont fontWithName:FONT_DEFAULE_BOLD size:16]];
    [self.loginName setTitleColor:KCOLOR_MAIN_BLUE forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setNotification:(NSDictionary *)notification {
    _notification = notification;
    
    [self.loginName setTitle:_notification[@"postUser"] forState:UIControlStateNormal];
    
    self.content.text    = _notification[@"content"];
    self.time.text       = _notification[@"time"];
    self.topicTitle.text = FORMAT_STRING(@"  %@", _notification[@"topicTitle"]);
    if([_notification[@"read"] boolValue]){
        self.content.textColor = KCOLOR_LIGHT_GRAY;
    }else{
        self.content.textColor = KCOLOR_MAIN_TEXT;
    }
    if([_notification[@"type"] intValue] == NotificationTypeAt){
        self.icon.image = [UIImage imageNamed:@"messageAT"];
    }else{
        self.icon.image = [UIImage imageNamed:@"messageComment"];
    }
}

@end
