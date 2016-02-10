//
// 侧滑Controller
// Created by DuWei on 15/12/18.
// Copyright (c) 2015 nutz.cn. All rights reserved.
//

#import "SlideViewController.h"
#import "SideMenuHeaderView.h"
#import <RESideMenu/RESideMenu.h>
#import "UITableView+Common.h"
#import "QRCodeScanViewController.h"
#import <JSBadgeView/JSBadgeView.h>
#import "Notification.h"
#import "UserInfoViewController.h"
#import "AppSetup.h"

@interface SlideViewController ()<RESideMenuDelegate>

@end

@implementation SlideViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor     = KCOLOR_CLEAR;
    self.tableView.dataSource     = self;
    self.tableView.delegate       = self;
    self.tableView.scrollsToTop   = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self receivedNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification)
                                                 name:APP_NOTIFICATION_UPDATE
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 自定义方法
// 收到通知
- (void)receivedNotification {
    // 刷新未读
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

- (UITableViewCell *)userHeaderView {
    SideMenuHeaderView *headerView = [[SideMenuHeaderView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[SideMenuHeaderView class] description]];
    if([User loginedUser]){
        headerView.user = [User loginedUser];
        headerView.logoutTappedBlock = ^(){
            [User logout];
            [self.tableView reloadData];
        };
        headerView.avatarTappedBlock = ^(){
            //用户信息
            [(UINavigationController*)self.sideMenuViewController.contentViewController pushViewController:[UserInfoViewController userInfoWithLoginName:[User loginedUser].loginname] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
        };
    }else{
        headerView.avatarTappedBlock = ^(){
            //[self testLogin];
            //return;
            QRCodeScanViewController *qrc = [QRCodeScanViewController controllerWithShowType:(ShowType)ShowTypePresent callback:^(NSString * result) {
                if(result && ![result hasPrefix:@"http"]){
                    [[APIManager manager] userInfoByToken:result callback:^(User *user, NSError *error) {
                        if(!error){
                            [User saveUser:user];
                            [self.tableView reloadData];
                        }else{
                            TIP_ALERT(@"令牌验证失败");
                        }
                    }];
                    return;
                }
                TIP_ALERT(@"这不是令牌,请扫描社区个人主页中的二维码");
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.sideMenuViewController presentViewController:qrc animated:YES completion:nil];
            });
        };
    }
    
    return headerView;
}

- (void)testLogin{
    NSString *token = @"";
    [[APIManager manager] userInfoByToken:token callback:^(User *user, NSError *error) {
        if(!error){
            [User saveUser:user];
            [self.tableView reloadData];
        }else{
            TIP_ALERT(@"令牌验证失败");
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        return 170;
    }
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        return [self userHeaderView];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"slideMenuCell"];
    
    cell.backgroundColor = KCOLOR_CLEAR;
    UIImage *icon = [UIImage imageNamed:@[@"sidemenu_QA", @"sidemenu_blog", @"sidemenu_setting"][indexPath.row-1]];
    [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.tintColor = KCOLOR_WHITE;
    cell.imageView.image = icon;
    cell.textLabel.text = @[@"技术问答", @"通知消息", @"设置"][indexPath.row-1];
    cell.textLabel.font = [UIFont systemFontOfSize:19];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.textLabel.textColor = KCOLOR_WHITE;

    cell.textLabel.shadowColor = [KCOLOR_BLACK colorWithAlphaComponent:0.3];
    cell.textLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    
    cell.selectedBackgroundView.backgroundColor =  [KCOLOR_BLACK colorWithAlphaComponent:0.2];
    // 通知添加badge
    if(indexPath.row == 2){
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
        NSInteger total = [[Notification queryAllUnRead] count];
        badgeView.badgeText = FORMAT_STRING(@"%ld", total);
        if(total == 0){
            badgeView.hidden = YES;
        }else{
            badgeView.hidden = NO;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1:
            break;
        case 2:{
            if(![User loginedUser]){
                TOAST_INFO(@"请登录后操作");
                return;
            }
            [(UINavigationController*)self.sideMenuViewController.contentViewController pushViewController:HHROUTER(@"/notifications") animated:NO];
        }
            break;
        case 3:
            [(UINavigationController*)self.sideMenuViewController.contentViewController pushViewController:HHROUTER(@"/settings") animated:NO];
            break;
        default:
            break;
    }
    [self.sideMenuViewController hideMenuViewController];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark fixed RESideMenu 滑动隐藏状态栏的问题
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.tableView reloadData];
}
- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end