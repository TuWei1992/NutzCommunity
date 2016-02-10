//
//  UserInfoHeaderView.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "SideMenuHeaderView.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Blur.h"

#define kAvatarSize 70
#define kNamePadding 15
#define kNameFontSize 20

@implementation SideMenuHeaderView {
    UIGestureRecognizer *gesture;
    
    UIImageView *avatarView;
    UILabel *nameLabel;
    UILabel *scoreLabel;
    UIButton *logoutLabel;
    UIView *transBg;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = KCOLOR_CLEAR;
        
        // 点击头像
        gesture = [UITapGestureRecognizer new];
        [gesture addTarget:self action:@selector(avaterTapped)];
        
        [self setupViews];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 存在用户信息, 显示
    if(!self.user){
        logoutLabel.hidden = YES;
        scoreLabel.text = @"点击头像登录";
        [avatarView addGestureRecognizer:gesture];
    }else{
        [avatarView addGestureRecognizer:gesture];
        logoutLabel.hidden = NO;
    }
}

#pragma mark Action
- (void)avaterTapped {
    if(self.avatarTappedBlock){
        self.avatarTappedBlock();
    }
}

- (void)logout {
    if(self.logoutTappedBlock){
        self.logoutTappedBlock();
    }
}

#pragma mark Getter
- (void)setUser:(User *)userInfo {
    _user = userInfo;
    //用户名
    nameLabel.text = userInfo.loginname;
    scoreLabel.text = [@"\uf15a" stringByAppendingFormat:@" %d分", userInfo.score];
    [logoutLabel setTitle:[@"\uf08b" stringByAppendingString:@" 注销"] forState:UIControlStateNormal];
    logoutLabel.hidden = NO;
    
    NSString *avatarUrl = nil;
    //修复头像历史遗留问题
    if([userInfo.avatarUrl rangeOfString:@"//gravatar.com/avatar/"].location != NSNotFound){
        avatarUrl = [NSString stringWithFormat:@"http:%@", userInfo.avatarUrl];
    }else{
        avatarUrl = userInfo.avatarUrl;
    }
    
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar"]];
}

#pragma mark Custom Mehod
- (void)setupViews {
    
    avatarView = [UIImageView new];
    avatarView.layer.cornerRadius = kAvatarSize / 2;
    avatarView.layer.borderWidth = 1;
    avatarView.layer.borderColor = KCOLOR_WHITE.CGColor;
    avatarView.layer.masksToBounds = YES;
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.userInteractionEnabled = YES;
    avatarView.image = [UIImage imageNamed:@"avatar"];
    [self addSubview:avatarView];
    
    nameLabel = [UILabel new];
    nameLabel.font = [UIFont fontWithName:FONT_DEFAULE_BOLD size:kNameFontSize];
    nameLabel.textColor = KCOLOR_WHITE;
    nameLabel.backgroundColor = KCOLOR_CLEAR;
    nameLabel.layer.shadowOpacity = 0.5;
    nameLabel.layer.shadowColor = KCOLOR_WHITE.CGColor;
    nameLabel.layer.shadowOffset = CGSizeMake(1, 1.0);
    [self addSubview:nameLabel];
    
    // 半透背景
    transBg = [UIView new];
    transBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self addSubview:transBg];
    
    scoreLabel = [UILabel new];
    scoreLabel.font = [UIFont fontWithName:FONT_ICONS size:16];
    scoreLabel.textColor = KCOLOR_WHITE;
    [transBg addSubview:scoreLabel];
    
    logoutLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutLabel.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:16];
    logoutLabel.titleLabel.textColor = KCOLOR_WHITE;
    [logoutLabel addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [transBg addSubview:logoutLabel];

    int avaterCenterX = (SCREEN_WIDTH / 2) - SIDE_MENU_CENTERX_OFFSET - kAvatarSize;
    // 头像居中
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kAvatarSize));
        make.height.equalTo(@(kAvatarSize));
        make.leftMargin.equalTo(@(avaterCenterX));
        make.top.equalTo(@(25));
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(avatarView);
        make.top.equalTo(avatarView.mas_bottom).offset(5);
    }]; 

    [transBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(35));
        make.width.equalTo(transBg.superview);
        make.bottom.equalTo(transBg.superview.mas_bottom);
    }];
    
    [scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(transBg);
        make.leftMargin.equalTo(@(kNamePadding));
        make.centerY.equalTo(transBg);
    }];
    
    int logoutX = (SCREEN_WIDTH / 2) - SIDE_MENU_CENTERX_OFFSET + kNamePadding;
    [logoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(transBg);
        make.right.equalTo(@(-logoutX));
        make.centerY.equalTo(transBg);
    }];

}

@end
