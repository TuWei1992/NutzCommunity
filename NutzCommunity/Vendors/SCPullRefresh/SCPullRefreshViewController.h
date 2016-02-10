//
//  SCPullRefreshViewController.h
//  v2ex-iOS
//
//  Created by Singro on 4/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+EmptyDataSet.h"
#import "BaseViewController.h"

@interface SCPullRefreshViewController : BaseViewController <UIScrollViewDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat tableViewInsertTop;
@property (nonatomic, assign) CGFloat tableViewInsertBottom;

@property (nonatomic, copy) void (^refreshBlock)();

- (void)beginRefresh;
- (void)endRefresh;

@property (nonatomic, copy) void (^loadMoreBlock)();
@property (nonatomic, assign) BOOL noMore;

- (void)beginLoadMore;
- (void)endLoadMore;

@end
