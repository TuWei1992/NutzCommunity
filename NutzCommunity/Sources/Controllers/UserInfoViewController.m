//
//  UserInfoViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/2/2.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UIImage+Color.h"
#import "UIImage+Blur.h"
#import "UserHeaderView.h"
#import "XTSegmentControl.h"
#import "UsersTopicViewController.h"
#import <ODRefreshControl/ODRefreshControl.h>

#define kHeaderViewHeight      200.0
#define kSegmentCellHeight     44.0
#define kScrollViewHeight      self.view.frame.size.height - NAVBAR_HEIGHT - kSegmentCellHeight

const void *_TABLEVIEW_SCROLLVIEWOFFSET = &_TABLEVIEW_SCROLLVIEWOFFSET;

@interface UserInfoViewController ()<UIScrollViewDelegate, XTSegmentControlDelegate>{
    int lastOffsetY;
    NSArray *controllers;
}
@property (strong, nonatomic) NSString         *userName;
@property (strong, nonatomic) UIScrollView     *containerView; // 容器
@property (strong, nonatomic) UserHeaderView   *headerView; //顶部view
@property (strong, nonatomic) UIScrollView     *bgScrollView; //装入两个controller
@property (strong, nonatomic) XTSegmentControl *titleSegments; //segment
@property (strong, nonatomic) ODRefreshControl *refreshControl;

@end

@implementation UserInfoViewController

+ (instancetype)userInfoWithLoginName:(NSString *)username {
    UserInfoViewController *vc = [UserInfoViewController new];
    vc.userName = username;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KCOLOR_WHITE;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    controllers = @[[UsersTopicViewController usersTopicWithTopics:[User loginedUser].recentTopics],
                    [UsersTopicViewController usersTopicWithTopics:[User loginedUser].recentReplies]];
    [self setupSubControllers];
    
    [self dropViewDidBeginRefreshing:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:KCOLOR_CLEAR]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:KCOLOR_CLEAR]];
    [self.navigationController.navigationBar setTintColor:KCOLOR_WHITE];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar  setShadowImage:[UIImage imageNamed:@"act_line"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:KCOLOR_WHITE]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:KCOLOR_MAIN_BLUE];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)loadView {
    [super loadView];
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.containerView];
    [self.refreshControl setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.titleSegments];
    [self.containerView addSubview:self.bgScrollView];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(kHeaderViewHeight);
    }];
    
    //table顶部留出导航栏的高度
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NAVBAR_HEIGHT);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.equalTo(self.view);
    }];
    
    [self.bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleSegments.mas_bottom);
        make.width.equalTo(self.containerView);
        make.height.mas_equalTo(kScrollViewHeight);
    }];
}

#pragma mark custom method
// 添加子控制器
- (void)setupSubControllers {
    
    for(UIViewController *vc in controllers){
        [self addChildViewController:vc];
    }
    
    CGFloat contentX = (self.childViewControllers.count) * self.bgScrollView.frame.size.width;
    self.bgScrollView.contentSize   = CGSizeMake(contentX, 0);
    self.bgScrollView.pagingEnabled = YES;
    
    // 添加默认控制器
    UIViewController *vc   = [self.childViewControllers firstObject];
    vc.view.frame                     = self.bgScrollView.bounds;
    [self.bgScrollView addSubview:vc.view];
}
// 刷新
- (void)dropViewDidBeginRefreshing:(id)sender {
    [[APIManager manager] userDetailInfoByName:self.userName callback:^(User *user, NSError *error) {
        if(!error){
            // 当前用户
            if([[User loginedUser].loginname isEqualToString:user.loginname]){
                user.ID = [User loginedUser].ID;
                user.accessToken = [User loginedUser].accessToken;
                [User saveUser:user];
            }
            
            [(UsersTopicViewController*)controllers[0] reloaData:[user recentTopics]];
            [(UsersTopicViewController*)controllers[1] reloaData:[user recentReplies]];
            [self.headerView refreshData:user];
        }
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - scrollView代理方法
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if(scrollView == self.bgScrollView){
        // 获得索引
        NSUInteger index = scrollView.contentOffset.x / self.bgScrollView.frame.size.width;
        [self.titleSegments endMoveIndex:index];
        
        // 添加控制器
        UIViewController *vc = self.childViewControllers[index];
        if (vc.view.superview){
            return;
        }
        
        vc.view.frame = scrollView.bounds;
        [self.bgScrollView addSubview:vc.view];
    }
    
}

// 滚动结束（手势导致
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView == self.bgScrollView){
         [self scrollViewDidEndScrollingAnimation:scrollView];
    }
}

// 正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.bgScrollView){
        // 取出绝对值 避免最左边往右拉时形变超过1
        if (self.titleSegments) {
            float offset = scrollView.contentOffset.x / scrollView.frame.size.width;
            if (offset > 0) {
                [self.titleSegments moveIndexWithProgress:offset];
            }
        }
    }
}

#pragma mark XTSegmentControl Delegate
- (void)segmentControl:(XTSegmentControl *)control selectedIndex:(NSInteger)index{
    CGFloat offsetX = index * self.bgScrollView.frame.size.width;
    
    CGFloat offsetY = self.bgScrollView.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    
    [self.bgScrollView setContentOffset:offset animated:YES];
}

#pragma mark observe
// 监听tableview offset
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == _TABLEVIEW_SCROLLVIEWOFFSET) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat offsetY = offset.y;
        //更新高度约束
        if(offsetY <= 0){
            [self.headerView avatarShouldHidden:-offsetY+NAVBAR_HEIGHT];
            [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(-offsetY+NAVBAR_HEIGHT);
            }];
            
            _containerView.contentInset = UIEdgeInsetsMake(MIN(kHeaderViewHeight-NAVBAR_HEIGHT, -offsetY), 0, 0, 0);
        }else{
            [self.headerView avatarShouldHidden:NAVBAR_HEIGHT];
            [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(NAVBAR_HEIGHT);
            }];
            _containerView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
    }
    
}

#pragma mark Getter
- (UIScrollView *)containerView {
    if(!_containerView){
        _containerView                              = [[UIScrollView alloc] initWithFrame:self.view.frame];
        _containerView.scrollsToTop                 = NO;
        _containerView.backgroundColor              = KCOLOR_CLEAR;
        _containerView.delegate                     = self;
        _containerView.alwaysBounceHorizontal       = NO;
        _containerView.alwaysBounceVertical         = YES;
        _containerView.showsVerticalScrollIndicator = NO;
        int inset                                   = kHeaderViewHeight-NAVBAR_HEIGHT;
        _containerView.contentInset                 = UIEdgeInsetsMake(inset, 0, 0, 0);
        _containerView.contentOffset                = CGPointMake(0, -(inset));
        _containerView.contentSize = (CGSize){SCREEN_WIDTH, kScrollViewHeight};

        // 观察者模式, 观察contentOffset的变化
        [_containerView addObserver:self
                     forKeyPath:NSStringFromSelector(@selector(contentOffset))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                        context:&_TABLEVIEW_SCROLLVIEWOFFSET];
    }
    return _containerView;
}

- (UserHeaderView *)headerView {
    if(!_headerView){
        _headerView = [[UserHeaderView alloc] initWithHeight:kHeaderViewHeight];
    }
    return _headerView;
}

-(UIScrollView *)bgScrollView{
    if(!_bgScrollView){
        _bgScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0,0, CGRectGetWidth(self.containerView.frame), kScrollViewHeight}];
        _bgScrollView.backgroundColor                = self.view.backgroundColor;
        _bgScrollView.delegate                       = self;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.showsVerticalScrollIndicator   = NO;
        _bgScrollView.bounces                        = NO;
        _bgScrollView.scrollsToTop                   = NO;
        _bgScrollView.alwaysBounceVertical = NO;
    }
    return _bgScrollView;
}

- (XTSegmentControl *)titleSegments{
    if(!_titleSegments){
        //添加滑块
        _titleSegments = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            SCREEN_WIDTH,
                                                                            kSegmentCellHeight)
                                                           Items:@[@"最近发表", @"最近回复"] delegate:self];
        _titleSegments.backgroundColor = KCOLOR_WHITE;
        UIView *line = [[UIView alloc] initWithFrame:(CGRect){0,kSegmentCellHeight-0.5,SCREEN_WIDTH,0.5}];
        [line setBackgroundColor:KCOLOR_LIGHT_GRAY];
        [_titleSegments addSubview:line];
    }
    return _titleSegments;
}

- (void)dealloc {
    // 取消观察
    [self.containerView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}


@end
