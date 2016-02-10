//
//  UserHeaderView.m
//  NutzCommunity
//
//  Created by DuWei on 16/2/3.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "UserHeaderView.h"
#import "UIImage+Blur.h"
#import "NSDate+TimeAgo.h"

#define kAvatarSize   90
#define kNameFontSize 20

@interface UserHeaderView()
@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel     *loginName;
@property (nonatomic, strong) UILabel     *createAt;
@property (nonatomic, strong) UILabel     *score;
@property (nonatomic, assign) CGFloat     headerHeight;
@end

@implementation UserHeaderView


- (instancetype)initWithHeight:(CGFloat)height {
    self = [super init];
    if(self){
        self.headerHeight = height;
        [self setupViews];
        [self refreshData:nil];
    }
    return self;
}

- (void)setupViews {
    self.clipsToBounds = YES;
    self.backgroundColor = KCOLOR_LIGHT_GRAY;
    
    [self addSubview:self.bgImage];
    [self addSubview:self.avatar];
    [self addSubview:self.loginName];
    [self addSubview:self.score];
    [self addSubview:self.createAt];
    
    [self.bgImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.loginName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-30);
        make.centerX.equalTo(self);
    }];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.loginName.mas_top).offset(-15);
        make.size.mas_equalTo(CGSizeMake(kAvatarSize, kAvatarSize));
        make.centerX.equalTo(self);
    }];
    [self.createAt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-5);
        make.left.equalTo(self).offset(10);
    }];
    [self.score mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-5);
        make.right.equalTo(self).offset(-10);
    }];
}
- (void)refreshData:(User *)userInfo {
    self.loginName.text = userInfo ? userInfo.loginname : @"...";
    self.score.text     = FORMAT_STRING(@"%d积分", userInfo ? userInfo.score : 0);
    self.createAt.text  = FORMAT_STRING(@"%@加入", userInfo ? [userInfo.createAt timeAgo] : @"刚刚");
    
    [self.bgImage sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:[[UIImage imageNamed:@"logo256"] darkImage] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _bgImage.alpha = 0.0;
        _bgImage.image = [image darkImage];
        [UIView animateWithDuration:0.3 animations:^{
            _bgImage.alpha = 1.0;
        }];
    }];
    
    NSString *avatarUrl = userInfo ? userInfo.avatarUrl : nil;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar"]];
}

- (void)avatarShouldHidden:(CGFloat)headerHeight {
    if(headerHeight >= NAVBAR_HEIGHT && headerHeight <= self.headerHeight){
        // 其他view 透明度
        float alpha = (headerHeight - NAVBAR_HEIGHT)/(self.headerHeight-NAVBAR_HEIGHT);
        self.avatar.alpha   = alpha;
        self.score.alpha    = alpha;
        self.createAt.alpha = alpha;
        
        // 用户名高度,30是loginName 相对于self 底部的距离,跟上面的约束一致
        if(headerHeight <= NAVBAR_HEIGHT + kNameFontSize){
            [self.loginName mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(-30+(NAVBAR_HEIGHT + kNameFontSize - headerHeight));
            }];
        }else{
            [self.loginName mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(-30);
            }];
        }
    }
}

#pragma mark getter
- (UIImageView *)bgImage {
    if(!_bgImage){
        _bgImage = [UIImageView new];
        [_bgImage setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _bgImage;
}

- (UIImageView *)avatar {
    if(!_avatar){
        _avatar = [UIImageView new];
        _avatar.layer.cornerRadius = kAvatarSize / 2;
        _avatar.layer.borderWidth  = 1;
        _avatar.layer.borderColor  = KCOLOR_WHITE.CGColor;
        _avatar.layer.masksToBounds = YES;
        _avatar.userInteractionEnabled = YES;
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatar;
}

- (UILabel *)loginName {
    if(!_loginName){
        _loginName = [UILabel new];
        _loginName.font = [UIFont fontWithName:FONT_DEFAULE_BOLD size:kNameFontSize];
        _loginName.textColor = [KCOLOR_WHITE colorWithAlphaComponent:0.8];
        _loginName.backgroundColor = KCOLOR_CLEAR;
        [_loginName sizeToFit];
    }
    return _loginName;
}

- (UILabel *)createAt {
    if(!_createAt){
        _createAt = [UILabel new];
        _createAt.font = [UIFont fontWithName:FONT_DEFAULE size:14];
        _createAt.textColor = [KCOLOR_WHITE colorWithAlphaComponent:0.8];
        _createAt.backgroundColor = KCOLOR_CLEAR;
        [_createAt sizeToFit];
    }
    return _createAt;
}

- (UILabel *)score {
    if(!_score){
        _score = [UILabel new];
        _score.font = [UIFont fontWithName:FONT_DEFAULE size:14];
        _score.textColor = [KCOLOR_WHITE colorWithAlphaComponent:0.8];
        _score.backgroundColor = KCOLOR_CLEAR;
        [_score sizeToFit];
    }
    return _score;
}

@end
