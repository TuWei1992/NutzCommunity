//
//  UserInfoHeaderView.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface SideMenuHeaderView : UITableViewCell

@property (nonatomic, strong) User *user;
// 点击头像
@property (nonatomic, copy) void(^avatarTappedBlock)();
// 点击退出登录
@property (nonatomic, copy) void(^logoutTappedBlock)();
@end
