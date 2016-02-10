//
//  SettingsViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/28.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "SettingsViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "JPushService.h"
#import "MBProgressHUD+Nutz.h"
#import "AppSetup.h"
#import "AppSignViewController.h"

@interface SettingsViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>{
    NSArray *iconArray;
    NSArray *titleArray;
}
@property (strong, nonatomic) UITableView *tableView;
// 推动开关
@property (strong, nonatomic) UISwitch    *pushSwitch;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    iconArray  = @[
                   @[@"\uf0a2", @"\uf27b"],
                   @[@"\uf014"],
                   @[@"\uf1d9", @"\uf08a", @"\uf1f9"]
                  ];
    titleArray = @[
                   @[@"推送通知", @"发帖签名"],
                   @[@"清理缓存"],
                   @[@"意见反馈", @"APP评分", @"关于"],
                  ];
}

- (void) loadView {
    [super loadView];
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame
                                                                  style:UITableViewStyleGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = KCOLOR_BG_COLOR;
    self.tableView.separatorColor  = [UIColor colorWithWhite:0.85 alpha:1.000];
    [self.view addSubview:self.tableView];
}
#pragma mark custom method
- (void)onPushSwitchOnOff:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    // 未登录
    if(![User loginedUser]){
        TOAST_INFO(@"请登录后操作");
        [self.sideMenuViewController presentLeftMenuViewController];
        [self.navigationController popViewControllerAnimated:NO];
        switchButton.on = NO;
        return;
    }
    
    TOAST_SHOW_WAIT;
    
    if(switchButton.isOn){
        if(![AppSetup isAllowedNotification]){
            TOAST_HIDE;
            switchButton.on = NO;
            TIP_ALERT(@"消息通知已关闭\n 请到 设置-通知-Nutz社区 中开启通知");
            return;
        }
        [AppSetup openPush:^(BOOL success){
            TOAST_HIDE;
            if(success){
                TOAST_SUCCESSES(@"设置成功");
            }else{
                TOAST_ERRORS(@"设置失败");
                [self.pushSwitch setOn:!self.pushSwitch.on];
            }
        }];
    } else {
        [AppSetup closePush:^(BOOL success){
            TOAST_HIDE;
            if(success){
                TOAST_SUCCESSES(@"设置成功");
            }else{
                TOAST_ERRORS(@"设置失败");
                [self.pushSwitch setOn:!self.pushSwitch.on];
            }
            TOAST_HIDE;
        }];
    }
}

// webview, sdwebimage 缓存, x.xmb
- (float)getAllCacheSize {
    
    float total = 0.0;
    total += [[NSURLCache sharedURLCache] currentDiskUsage];
    total += [[NSURLCache sharedURLCache] currentMemoryUsage];
    total += [[SDImageCache sharedImageCache] getSize];
    
    return total/1024.0/1024.0;
}

- (void)cleanAllCache {
    TOAST_SHOW_WAITS(@"清理中...");
    [[SDImageCache sharedImageCache] cleanDisk];
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    TOAST_HIDE;
    TOAST_SUCCESSES(@"清理完成");
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)titleArray[section]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell    = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:@"SettingCell"];
    cell.textLabel.textColor = KCOLOR_MAIN_TEXT;
    cell.imageView.tintColor = KCOLOR_MAIN_BLUE;
    cell.textLabel.font      = [UIFont fontWithName:FONT_DEFAULE size:17];

    
    UIImage *icon        = [UIImage iconWithFont:FONT_ICON_SIZE(18)
                                           named:iconArray[indexPath.section][indexPath.row]
                                   withTintColor:KCOLOR_MAIN_BLUE
                                    clipToBounds:NO
                                         forSize:18];
    cell.textLabel.text  = titleArray[indexPath.section][indexPath.row];
    cell.imageView.image = icon;
    //推送开关
    if(indexPath.section == 0 && indexPath.row == 0){
        cell.accessoryView = self.pushSwitch;
    }else if(indexPath.section == 1 && indexPath.row == 0){// 缓存大小
        UILabel *cacheSize = [UILabel new];
        [cacheSize setTextColor:KCOLOR_MAIN_BLUE];
        [cacheSize setText:FORMAT_STRING(@"%.2fMB", [self getAllCacheSize])];
        [cacheSize sizeToFit];
        cell.accessoryView = cacheSize;
    }else{
        cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0 && indexPath.row == 1){
        if(![User loginedUser]){
            TOAST_INFO(@"请登录后操作");
            [self.sideMenuViewController presentLeftMenuViewController];
            return;
        }
        [self push:[AppSignViewController new]];
    }
    if(indexPath.section == 1 && indexPath.row == 0){// 缓存大小
        [self cleanAllCache];
        [tableView reloadData];
    }
    if(indexPath.section == 2 && indexPath.row == 0){//反馈
        TIP_ALERT(@"\n请到论坛发帖反馈, 并@相关人员");
    }
    if(indexPath.section == 2 && indexPath.row == 1){//评分
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/nutz-she-qu/id1082195150?l=zh&ls=1&mt=8"]];
    }
    if(indexPath.section == 2 && indexPath.row == 2){//评分
        [self push:HHROUTER(@"about")];
    }
}

#pragma mark fixed RESideMenu 滑动隐藏状态栏的问题
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark Getter
- (UISwitch *)pushSwitch {
    if(!_pushSwitch){
        _pushSwitch             = [[UISwitch alloc] init];
        _pushSwitch.onTintColor = KCOLOR_MAIN_BLUE;
        
        BOOL on1                = [User loginedUser] != nil;
        BOOL on2                = [AppSetup isAllowedNotification];
        BOOL on3                = [FIND_DEFAULTS(JPUSH_ENABLE_SETTING_KEY) isEqualToString:JPUSH_ENABLE_SETTING_ON];
        _pushSwitch.on          = on1 && on2 && on3;
        
        [_pushSwitch addTarget:self action:@selector(onPushSwitchOnOff:) forControlEvents:UIControlEventValueChanged];
    }
    return _pushSwitch;
}

@end
