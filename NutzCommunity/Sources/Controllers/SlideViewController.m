//
// 侧滑Controller
// Created by DuWei on 15/12/18.
// Copyright (c) 2015 nutz.cn. All rights reserved.
//

#import "SlideViewController.h"
#import "UserInfoHeaderView.h"
#import <RESideMenu/RESideMenu.h>
#import "UITableView+Common.h"

@interface SlideViewController ()<RESideMenuDelegate>

@end

@implementation SlideViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = NO;
    self.tableView.scrollsToTop = NO;
    self.tableView.backgroundColor = [UIColor colorWithHex:0x495663];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)setContentViewController:(UIViewController *)viewController {
    //    viewController.hidesBottomBarWhenPushed = YES;
    //    UINavigationController *nav = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
    //    //UIViewController *vc = nav.viewControllers[0];
    //    //vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    //    [nav pushViewController:viewController animated:NO];
    //
    //    [self.sideMenuViewController hideMenuViewController];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 170;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UserInfoHeaderView *headerView = [[UserInfoHeaderView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[UserInfoHeaderView class] description]];
    User *userInfo = [User new];
    userInfo.loginname = @"TuWei";
    userInfo.avatarUrl = @"https://nutz.cn/yvr/u/tuwei1992/avatar";
    userInfo.score = 99;
    headerView.userInfo = userInfo;
    
    return headerView;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"slideMenuCell"];
    
    cell.backgroundColor = COLOR_CLEAR;
    UIImage *icon = [UIImage imageNamed:@[@"sidemenu_QA", @"sidemenu-software", @"sidemenu_blog", @"sidemenu_setting", @"sidemenu-night"][indexPath.row]];
    [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.tintColor = COLOR_WHITE;
    cell.imageView.image = icon;
    cell.textLabel.text = @[@"技术问答", @"开源软件", @"新闻", @"设置", @"夜间模式"][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:19];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.textLabel.textColor = COLOR_WHITE;

    cell.textLabel.shadowColor = [COLOR_BLACK colorWithAlphaComponent:0.3];
    cell.textLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    
    cell.selectedBackgroundView.backgroundColor =  [COLOR_BLACK colorWithAlphaComponent:0.2];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end