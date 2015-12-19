//
// 侧滑Controller
// Created by DuWei on 15/12/18.
// Copyright (c) 2015 nutz.cn. All rights reserved.
//

#import "RootViewController.h"
@interface RootViewController ()

@end

@implementation RootViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.bounces = NO;

    self.tableView.backgroundColor = COLOR_LIGHT_GRAY;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end