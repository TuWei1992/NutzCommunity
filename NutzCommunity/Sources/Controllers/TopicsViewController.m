//
//  TopicsViewController.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/21.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "TopicsViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "TopicTableViewCell.h"
#import "UITableView+Common.h"
#import "TopicDetailViewController.h"
#import "NewTopicViewController.h"

static NSString *CellIdentifier = @"TopicCellIdentifier";

@interface TopicsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) int  page;
@end

@implementation TopicsViewController

+ (instancetype)topicsWithTabType:(NSString *)tabType {
    TopicsViewController *vc = [TopicsViewController new];
    vc.tabType = tabType;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [Topic tabTypeName:self.tabType];
    [self beginRefresh];
}

#pragma mark Custom Method
- (void)loadView {
    [super loadView];
    
    self.topics                    = [NSMutableArray new];
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"TopicTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:self.tableView];
    
    @weakify(self);
    self.loadMoreBlock = ^{
        @strongify(self);
        [[APIManager manager] topicsByTab:self.tabType page:self.page + 1 callback:^(NSArray* topics, NSError *error) {
            
            if(topics){
                //refresh
                if(self.page == 0){
                    [self.topics removeAllObjects];
                }
                
                [self.topics addObjectsFromArray:topics];
                [self.tableView reloadData];
                
                if(topics.count >= NUTZ_PAGE_SIZE){
                    self.page += 1;
                }else{
                    // 没有更多
                    self.noMore = YES;
                }
                
            }
            
            [self endRefresh];
            [self endLoadMore];
        }];
    };
    self.refreshBlock = ^{
        @strongify(self);
        self.page = 0;
        self.noMore = NO;
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
    Topic *topic = self.topics[indexPath.row];

    [self.navigationController pushViewController:HHROUTER(FORMAT_STRING(@"/topicDetail/%@", topic.ID))
                                         animated:YES];
}

#pragma mark EmptyState
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"empty_detail"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"当前版块无话题";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0f],
                                 NSForegroundColorAttributeName: [UIColor grayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"这里还没有话题, 赶快点击 \"+\", 发帖抢沙发吧~";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -self.tableView.tableHeaderView.frame.size.height/2.0f - 64;
}

@end
