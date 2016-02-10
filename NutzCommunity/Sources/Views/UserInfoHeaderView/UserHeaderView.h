//
//  UserHeaderView.h
//  NutzCommunity
//
//  Created by DuWei on 16/2/3.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHeaderView : UIView
- (instancetype)initWithHeight:(CGFloat)height;

- (void)refreshData:(User *)userInfo;
// 缩放头像
- (void)avatarShouldHidden:(CGFloat)headerHeight;
@end
