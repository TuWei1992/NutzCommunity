//
//  NotificationsViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/25.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UITableView+Common.h"
#import "KxMenu.h"

static NSString *CellIdentifier = @"NotifyCellIdentifier";

@interface NotificationsViewController ()<UITableViewDelegate, UITableViewDataSource> {
    // flag: 查看未读
    BOOL showUnRead;
}
@property (nonatomic, assign) int  page;
@property (nonatomic, strong) NSMutableArray    *notifis;
@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通知消息";
    
    // 菜单按钮
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(navMoreClicked)]
                                      animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification)
                                                 name:APP_NOTIFICATION_UPDATE
                                               object:nil];
    [self beginRefresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Custom Method
// 收到通知
- (void)receivedNotification {
    [self beginRefresh];
}

- (void)loadData {
    //条件
    NSArray *dbNotifis = showUnRead ? [Notification queryAllUnRead] : [Notification queryAll];
    if(dbNotifis){
        //refresh
        if(self.page == 0){
            [self.notifis removeAllObjects];
        }
        
        [self.notifis addObjectsFromArray:[[dbNotifis reverseObjectEnumerator] allObjects]];
        [self.tableView reloadData];
        
        // 没有更多
        self.noMore = YES;
    }
    [self endRefresh];
}

- (void)navMoreClicked {
    NSArray *menus = @[
                       [KxMenuItem menuItem: !showUnRead ? @"查看未读" : @"查看全部"
                                      image:[UIImage imageNamed:@"tips_menu_icon_status"]
                                     target:self
                                     action:@selector(showNotifisOfType)],
                       
                       [KxMenuItem menuItem:@"全部标注已读"
                                      image:[UIImage imageNamed:@"tips_menu_icon_mkread"]
                                     target:self
                                     action:@selector(markReadAll)],
                      ];
    
    CGRect senderFrame = CGRectMake(SCREEN_WIDTH - (IS_IPHONE6P ? 40: 36), NAVBAR_HEIGHT, 0, 0);
    [KxMenu showMenuInView:self.view
                  fromRect:senderFrame
                 menuItems:menus];
}

- (void)showNotifisOfType {
    showUnRead = !showUnRead;
    [self beginRefresh];
}

- (void)markReadAll {
    [Notification updateAllRead];
}

- (void)loadView {
    [super loadView];
    
    self.notifis                    = [NSMutableArray new];
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self.view addSubview:self.tableView];
    
    // 从数据库一次性加载消息
    @weakify(self);
    self.refreshBlock = ^{
        @strongify(self);
        [self performSelector:@selector(loadData) withObject:self afterDelay:0.1];
    };
}



#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifis.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NotificationTableViewCell" owner:self options:nil] lastObject];
    }
    
    cell.notification = self.notifis[indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:56];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *notify = self.notifis[indexPath.row];
    //标为已读
    [Notification updateReadById:[notify[@"id"] intValue]];
    [self.navigationController pushViewController:HHROUTER(FORMAT_STRING(@"/topicDetail/%@", notify[@"topicId"]))
                                         animated:YES];
}

// 滑动删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //请求数据源提交的插入或删除指定行接收者。
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        if (indexPath.row<[self.notifis count]) {
            NSDictionary *notify = self.notifis[indexPath.row];
            [Notification deleteById:[notify[@"id"] intValue]];
            
            [self.notifis removeObjectAtIndex:indexPath.row];//移除数据源的数据
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
        }
    }
}

#pragma mark EmptyState
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"empty_message"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"没有消息";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0f],
                                 NSForegroundColorAttributeName: [UIColor grayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"快点去Nutz.cn多攒点人气吧~";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

    
@end
