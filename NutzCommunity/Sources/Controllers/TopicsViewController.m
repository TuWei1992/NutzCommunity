//
//  TopicsViewController.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/21.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "TopicsViewController.h"
#import "TopicTableViewCell.h"
#import "UITableView+Common.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <RESideMenu/RESideMenu.h>
#import "TopicDetailViewController.h"

static NSString *CellIdentifier = @"TopicCellIdentifier";

@interface TopicsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) int            page;
@property (nonatomic, strong) NSMutableArray *topics;
@end

@implementation TopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Nutz社区";
    [self setupBarItem];
    
    [self beginRefresh];
    
}


#pragma mark Custom Method
- (void)setupBarItem {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sideMenu"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(openSideMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)openSideMenu {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)loadView {
    [super loadView];
    
    self.topics                    = [NSMutableArray new];
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = COLOR_WHITE;
    [self.tableView registerNib:[UINib nibWithNibName:@"TopicTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:self.tableView];
    
    @weakify(self);
    self.loadMoreBlock = ^{
        @strongify(self);
        [[APIManager manager] topicsByTab:@"ask" page:self.page + 1 callback:^(NSArray* topics, NSError *error) {
            
            if(topics){
                //refresh
                if(self.page == 0){
                    [self.topics removeAllObjects];
                }
                
                [self.topics addObjectsFromArray:topics];
                [self.tableView reloadData];
                self.page += 1;
            }
            
            [self endRefresh];
            [self endLoadMore];
        }];
    };
    self.refreshBlock = ^{
        @strongify(self);
        self.page = 0;
        self.loadMoreBlock();
    };
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topics.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *topic = self.topics[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:CellIdentifier cacheByIndexPath:indexPath configuration:^(TopicTableViewCell *cell) {
        cell.topic = topic;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TopicTableViewCell" owner:self options:nil] lastObject];
    }
    
    cell.topic = self.topics[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TopicDetailViewController *detailVC = [TopicDetailViewController new];
    detailVC.topic = self.topics[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
