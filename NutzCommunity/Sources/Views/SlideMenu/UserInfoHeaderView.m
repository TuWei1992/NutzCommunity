//
//  UserInfoHeaderView.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "UserInfoHeaderView.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Blur.h"

#define kAvatarSize 60
#define kNamePadding 15
#define kNameFontSize 20

@interface UserInfoHeaderView ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *logoutLabel;

@end

@implementation UserInfoHeaderView

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = COLOR_CLEAR;
        [self setupViews];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
}

#pragma mark Getter
- (void)setUserInfo:(User *)userInfo {
    _userInfo = userInfo;
    
    //用户名
    self.nameLabel.text = userInfo.loginname;
    self.scoreLabel.text = [@"\uf2af" stringByAppendingFormat:@" %d分", userInfo.score];
    self.logoutLabel.text = [@"\uf29f" stringByAppendingString:@" 注销"];
    
    NSString *avatarUrl = nil;
    //修复头像历史遗留问题
    if([userInfo.avatarUrl rangeOfString:@"//gravatar.com/avatar/"].location != NSNotFound){
        avatarUrl = [NSString stringWithFormat:@"http:%@", userInfo.avatarUrl];
    }else{
        avatarUrl = userInfo.avatarUrl;
    }
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"Avatar"]];
}

#pragma mark Custom Mehod
- (void)setupViews {
    
    self.avatarView = [UIImageView new];
    self.avatarView.layer.cornerRadius = kAvatarSize / 2;
    self.avatarView.layer.borderWidth = 1;
    self.avatarView.layer.borderColor = COLOR_WHITE.CGColor;
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.avatarView];
    
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont fontWithName:@"Kailasa" size:kNameFontSize];//[UIFont systemFontOfSize:kNameFontSize weight:UIFontWeightBold];
    self.nameLabel.textColor = COLOR_WHITE;
    self.nameLabel.backgroundColor = COLOR_CLEAR;
    self.nameLabel.layer.shadowOpacity = 0.8;
    self.nameLabel.layer.shadowColor = COLOR_BLACK.CGColor;
    self.nameLabel.layer.shadowOffset = CGSizeMake(1, 1.0);
    [self addSubview:self.nameLabel];
    
    // 半透背景
    UIView *transBg = [UIView new];
    transBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self addSubview:transBg];
    
    self.scoreLabel = [UILabel new];
    self.scoreLabel.font = [UIFont fontWithName:FONT_IONICONS size:16];
    self.scoreLabel.textColor = COLOR_WHITE;
//    self.scoreLabel.layer.shadowOpacity = 0.8;
//    self.scoreLabel.layer.shadowColor = COLOR_BLACK.CGColor;
//    self.scoreLabel.layer.shadowOffset = CGSizeMake(1, 1.0);
    [transBg addSubview:self.scoreLabel];
    
    self.logoutLabel = [UILabel new];
    self.logoutLabel.font = [UIFont fontWithName:FONT_IONICONS size:16];
    self.logoutLabel.textColor = COLOR_WHITE;
//    self.logoutLabel.layer.shadowOpacity = 0.8;
//    self.logoutLabel.layer.shadowColor = COLOR_BLACK.CGColor;
//    self.logoutLabel.layer.shadowOffset = CGSizeMake(1, 1.0);
    [transBg addSubview:self.logoutLabel];

    int avaterCenterX = (SCREEN_WIDTH / 2) - SIDE_MENU_CENTERX_OFFSET - kAvatarSize;
    // 头像居中
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kAvatarSize));
        make.height.equalTo(@(kAvatarSize));
        make.leftMargin.equalTo(@(avaterCenterX));
        make.top.equalTo(@(25));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_avatarView);
        make.top.equalTo(_avatarView.mas_bottom).offset(kNamePadding);
    }]; 

    [transBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(35));
        make.width.equalTo(transBg.superview);
        make.bottom.equalTo(transBg.superview.mas_bottom);
    }];
    
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(transBg);
        make.leftMargin.equalTo(@(kNamePadding));
        make.centerY.equalTo(transBg);
    }];
    
    int logoutX = (SCREEN_WIDTH / 2) - SIDE_MENU_CENTERX_OFFSET + kNamePadding;
    [self.logoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(transBg);
        make.right.equalTo(@(-logoutX));
        make.centerY.equalTo(transBg);
    }];
}

@end
