//
//  MainViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/23.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "MainViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "XTSegmentControl.h"
#import "TopicsViewController.h"
#import "NewTopicViewController.h"
#import <LGPlusButtonsView/LGPlusButtonsView.h>
#import <JSBadgeView/JSBadgeView.h>
#import "Notification.h"

#define kChannelSegmentControl_Height 44.0f
#define kBackBtnWidth                 44.0f

@interface MainViewController ()<UIScrollViewDelegate, XTSegmentControlDelegate>

/** 下面的内容栏 */
@property (nonatomic,strong) UIScrollView      *bigScrollView;
@property (nonatomic,assign) NSInteger         curIndex;
@property (nonatomic,strong) XTSegmentControl  *titleSegments;
@property (nonatomic,strong) LGPlusButtonsView *addButton;
@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KCOLOR_WHITE;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // new topic button
    [self.view insertSubview:self.addButton aboveSubview:self.bigScrollView];
    
    self.titles      = @[@"问答", @"新闻",@"分享",@"灌水",@"招聘",@"短点"];
    self.controllers = @[[TopicsViewController topicsWithTabType:TAB_ASK],
                         [TopicsViewController topicsWithTabType:TAB_NEWS],
                         [TopicsViewController topicsWithTabType:TAB_SHARE],
                         [TopicsViewController topicsWithTabType:TAB_NB],
                         [TopicsViewController topicsWithTabType:TAB_JOB],
                         [TopicsViewController topicsWithTabType:TAB_SHORT]];
    
    [self setupBarItem];
    [self setupSubControllers];
    [self updateUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification)
                                                 name:APP_NOTIFICATION_UPDATE
                                               object:nil];
    //更新角标
    [self receivedNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 自定义方法
// 收到通知
- (void)receivedNotification{
    [self setupBarItem];
}

- (void)setupBarItem {
    self.navigationItem.titleView = self.titleSegments;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame: CGRectMake(0, 0, 44, 44)];
    [button setImage:[[UIImage imageNamed:@"sideMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [button setTintColor:KCOLOR_MAIN_BLUE];
    [button addTarget:self action:@selector(openSideMenu) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftItem;

    NSInteger total = [[Notification queryAllUnRead] count];
    if(total == 0){
        return;
    }
    JSBadgeView *badgeView            = [[JSBadgeView alloc] initWithParentView:button
                                                                      alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgePositionAdjustment = CGPointMake(0, 8);
    badgeView.badgeText               = FORMAT_STRING(@"%ld", total);
}

//更新用户信息
- (void)updateUserInfo {
    //未登录就不更新了
    if(![User loginedUser]){
        return;
    }
    [[APIManager manager] userInfoByToken:[User loginedUser].accessToken callback:^(User *user, NSError *error) {
        if(!error){
            [User saveUser:user];
        }
    }];
}

// 添加子控制器
- (void)setupSubControllers {
    
    for(UIViewController *vc in self.controllers){
        [self addChildViewController:vc];
    }
    
    CGFloat contentX = (self.childViewControllers.count) * self.view.bounds.size.width;
    self.bigScrollView.contentSize   = CGSizeMake(contentX, 0);
    self.bigScrollView.pagingEnabled = YES;
    
    // 添加默认控制器
    TopicsViewController *vc          = [self.childViewControllers firstObject];
    vc.view.frame                     = self.view.bounds;
    self.addButton.observedScrollView = vc.tableView;
    [self.bigScrollView addSubview:vc.view];
}

// 打开侧边
- (void)openSideMenu {
    [self.sideMenuViewController presentLeftMenuViewController];
}

// 添加话题
- (void)goAddNewTopic {
    // 未登录
    if(![User loginedUser]){
        TOAST_INFO(@"请登录后操作");
        [self openSideMenu];
        return;
    }
    TopicsViewController *curVC = self.controllers[self.curIndex];
    NewTopicViewController *addTopic = (NewTopicViewController*)HHROUTER(@"/newTopic");
    
    addTopic.tabTypeKey=curVC.tabType;
    // 发布topic
    addTopic.sendTopic = ^(Topic *topic){
        if(topic){
            [[APIManager manager] newTopic:topic.title
                                   tabType:topic.tab
                                   content:topic.content
                               accessToken:[User loginedUser].accessToken
                                  callback:^(NSString *topicId, NSError *error) {
                                      if(!error){
                                          
                                          topic.ID = topicId;
                                          [Topic delTopic];
                                          // 添加发送的topic
                                          if(curVC.topics && curVC.tableView && [curVC.tabType isEqualToString:topic.tab]){
                                              [curVC.topics insertObject:topic atIndex:0];
                                              [curVC.tableView reloadData];
                                              [curVC.tableView scrollsToTop];
                                          }
                                      }
                                  }];
        }
    };
    
    [self.sideMenuViewController presentViewController:[[BaseNavViewController alloc] initWithRootViewController:addTopic]
                                              animated:YES
                                            completion:nil];
}

#pragma mark - scrollView代理方法
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.bigScrollView.frame.size.width;
    [self.titleSegments endMoveIndex:index];
    
    // 添加控制器
    TopicsViewController *vc = self.childViewControllers[index];
    // 切换addButton需要处理的scrollview
    self.addButton.observedScrollView = vc.tableView;
    self.curIndex = index;
    
    if (vc.view.superview){
        return;
    }
    
    vc.view.frame = scrollView.bounds;
    [self.bigScrollView addSubview:vc.view];
    self.addButton.observedScrollView = vc.tableView;
}

// 滚动结束（手势导致
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

// 正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 取出绝对值 避免最左边往右拉时形变超过1
    if (self.titleSegments) {
        float offset = scrollView.contentOffset.x / scrollView.frame.size.width;
        if (offset > 0) {
            [self.titleSegments moveIndexWithProgress:offset];
        }
    }
}

#pragma mark XTSegmentControl Delegate
- (void)segmentControl:(XTSegmentControl *)control selectedIndex:(NSInteger)index{
    CGFloat offsetX = index * self.bigScrollView.frame.size.width;
    
    CGFloat offsetY = self.bigScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    
    // 切换addButton需要处理的scrollview
    TopicsViewController *vc = self.childViewControllers[index];
    self.addButton.observedScrollView = vc.tableView;
    self.curIndex = index;
    
    [self.bigScrollView setContentOffset:offset animated:YES];
}

#pragma mark - getter
-(UIScrollView *)bigScrollView{
    if(!_bigScrollView){
        _bigScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _bigScrollView.backgroundColor                = self.view.backgroundColor;
        _bigScrollView.delegate                       = self;
        _bigScrollView.showsHorizontalScrollIndicator = NO;
        _bigScrollView.showsVerticalScrollIndicator   = NO;
        //_bigScrollView.bounces                        = NO;
        [self.view addSubview:_bigScrollView];
    }
    return _bigScrollView;
}

- (XTSegmentControl *)titleSegments{
    if(!_titleSegments){
        //添加滑块
        _titleSegments = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            SCREEN_WIDTH - kBackBtnWidth - 20,
                                                                            kChannelSegmentControl_Height)
                                                           Items:self.titles delegate:self];
    }
    return _titleSegments;
}

- (LGPlusButtonsView *)addButton {
    if(!_addButton){
        _addButton = [[LGPlusButtonsView alloc] initWithNumberOfButtons:1 firstButtonIsPlusButton:YES showAfterInit:YES actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index) {
            [self goAddNewTopic];
        }];
        
        [_addButton setButtonsTitles:@[@"+"] forState:UIControlStateNormal];
        [_addButton setButtonsBackgroundColor:KCOLOR_MAIN_BLUE forState:UIControlStateNormal];
        [_addButton setButtonsSize:CGSizeMake(60.f, 60.f) forOrientation:LGPlusButtonsViewOrientationAll];
        [_addButton setButtonsLayerCornerRadius:60.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
        [_addButton setButtonsTitleFont:[UIFont fontWithName:FONT_DEFAULE_BOLD size:32.f] forOrientation:LGPlusButtonsViewOrientationAll];
        //[_addButton setButtonsLayerShadowOpacity:0.5];
        //[_addButton setButtonsLayerShadowRadius:2.f];
        //[_addButton setButtonsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
    }
    return  _addButton;
}


@end
