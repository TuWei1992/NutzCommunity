//
//  AboutViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/2/1.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "AboutViewController.h"
#import "UIImage+Color.h"
#import "UIImage+Blur.h"

@interface AboutViewController ()
@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel     *slogan;
@property (nonatomic, strong) UILabel     *version;
@property (nonatomic, strong) UILabel     *cpRight;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    [self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nutz"]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:KCOLOR_CLEAR]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:KCOLOR_CLEAR]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar  setShadowImage:[UIImage imageNamed:@"act_line"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:KCOLOR_WHITE]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.bgImage];
    [self.view addSubview:self.logo];
    [self.view addSubview:self.slogan];
    [self.view addSubview:self.version];
    [self.view addSubview:self.cpRight];
    
    [self.bgImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(128, 128));
        make.top.equalTo(self.view).offset(NAVBAR_HEIGHT + 30);
        make.centerX.equalTo(self.view);
    }];
    
    [self.slogan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logo.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
    }];
    
    [self.cpRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-15);
        make.centerX.equalTo(self.view);
    }];
    
    [self.version mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.cpRight.mas_top).offset(-15);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark Getter
- (UIImageView*)logo {
    if(!_logo){
        _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo256"]];
        _logo.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logo;
}
- (UIImageView*)bgImage {
    if(!_bgImage){
        _bgImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"nutz.jpg"] lightImage]];
        _bgImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bgImage;
}

- (UILabel *)slogan {
    if(!_slogan){
        _slogan = [UILabel new];
        _slogan.textColor = KCOLOR_MAIN_TEXT;
        _slogan.font      = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
        _slogan.text      = NUTZ_SLOGAN;
        _slogan.layer.shadowOpacity = 0.3;
        _slogan.layer.shadowColor   = KCOLOR_BLACK.CGColor;
        _slogan.layer.shadowOffset  = CGSizeMake(1, 1.0);
        [_slogan sizeToFit];
    }
    return _slogan;
}

- (UILabel *)version {
    if(!_version){
        _version = [UILabel new];
        _version.textColor = KCOLOR_MAIN_BLUE;
        _version.font      = [UIFont systemFontOfSize:14];
        _version.text      = FORMAT_STRING(@"Ver: %@(%@)",VERSION_STRING, VERSION_BUILD);
        [_version sizeToFit];
    }
    return _version;
}

- (UILabel *)cpRight {
    if(!_cpRight){
        _cpRight = [UILabel new];
        _cpRight.textColor = KCOLOR_LIGHT_GRAY;
        _cpRight.font      = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _cpRight.text      = @"Copyright © 2016 Nutz.cn All Rights Reserved";
        [_cpRight sizeToFit];
    }
    return _cpRight;
}

@end
