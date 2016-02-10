//
//  UsersTopicViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/2/5.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "UsersTopicViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "TopicTableViewCell.h"
#import "TopicDetailViewController.h"
#import "NewTopicViewController.h"
#import "UIScrollView+EmptyDataSet.h"

static NSString *CellIdentifier = @"TopicCellIdentifier";

@interface UsersTopicViewController ()<UITableViewDelegate, UITableViewDataSource,
                                        DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) NSMutableArray    *topics;
@end

@implementation UsersTopicViewController

+ (instancetype)usersTopicWithTopics:(NSArray *)topics {
    UsersTopicViewController *vc = [UsersTopicViewController new];
    vc.topics = [[NSMutableArray alloc] initWithArray:topics];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.tableView];
}

- (void)reloaData:(NSArray *)topics {
    [self.topics removeAllObjects];
    [self.topics addObjectsFromArray:topics];
    [self.tableView reloadData];
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
    NSString *text = @"没有话题";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0f],
                                 NSForegroundColorAttributeName: [UIColor grayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"您还没有话题, 赶快到各个板块发帖吧~";
    
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


#pragma mark getter 
- (UITableView *)tableView {
    if(!_tableView){
        _tableView                      = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.separatorStyle       = UITableViewCellSeparatorStyleNone;
        _tableView.delegate             = self;
        _tableView.dataSource           = self;
        _tableView.alwaysBounceVertical = NO;
        _tableView.emptyDataSetSource   = self;
        _tableView.emptyDataSetDelegate = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TopicTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    }
    
    return _tableView;
}

@end
