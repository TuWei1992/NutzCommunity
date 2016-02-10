//
//  AppSignTableViewCell.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/31.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "AppSignTableViewCell.h"

@implementation AppSignTableViewCell

- (void)awakeFromNib {
    //setup
    self.loginname.textColor = KCOLOR_MAIN_BLUE;
    self.loginname.text      = [User loginedUser].loginname;
    self.content.textColor   = KCOLOR_MAIN_TEXT;
    
    self.avatar.layer.cornerRadius = 44/2;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[User loginedUser].avatarUrl]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
