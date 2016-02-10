//
//  TopicDetailViewController.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/23.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "TopicDetailViewController.h"
#import <LGPlusButtonsView/LGPlusButtonsView.h>
#import <GHMarkdownParser/GHMarkdownParser.h>
#import <ShareSDK/ShareSDK.h>
#import "JDFPeekabooCoordinator.h"
#import "WebViewJavascriptBridge.h"
#import "SCBubbleRefreshView.h"
#import "TOWebViewController.h"
#import "BlurCommentView.h"
#import "SCActionSheet.h"
#import "V2ActionCellView.h"
#import "UserInfoViewController.h"

#define kRefreshViewHeight   44

@interface TopicDetailViewController ()<UIWebViewDelegate, UIScrollViewDelegate> {
    // 暂存的评论
    NSString *savedComment;
    BOOL refreshing;
    // 旋转屏幕后webview inset 的高度差
    int  kRotateInsetVariable;
    Topic *tp;
}
@property (nonatomic, strong) SCBubbleRefreshView *refreshView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) LGPlusButtonsView *replyButton;
@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;
@property (nonatomic, strong) SCActionSheet *actionSheet;
@end

@implementation TopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Detail";
    self.view.backgroundColor = KCOLOR_BG_COLOR;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    //设置话题id
    if(self.params[@"topicId"]){
        self.topicId = self.params[@"topicId"];
    }
    
    [self setupUI];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                               action:@selector(navMoreClicked)]
                                      animated:NO];
    //竖屏
    kRotateInsetVariable = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    [super viewWillDisappear:animated];
    
    //取消滚动隐藏navbar
    self.scrollCoordinator.topViewItems = nil;
    [self.scrollCoordinator disable];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //滚动隐藏navbar
    self.scrollCoordinator.scrollView = self.webView.scrollView;
    self.scrollCoordinator.topView = self.navigationController.navigationBar;
    self.scrollCoordinator.topViewItems = @[self.navigationItem.leftBarButtonItem.customView];
    [self.scrollCoordinator enable];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //webview inset 高度差值
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)){
        kRotateInsetVariable = 20;
    } else if(UIDeviceOrientationIsPortrait(deviceOrientation)) {
        kRotateInsetVariable = 0;
    }
}

#pragma mark private methods
//分享
- (void)navMoreClicked {
    if(refreshing){
        return;
    }
    
    V2ActionCellView *shareAction = [[V2ActionCellView alloc] initWithTitles:nil imageNames:@[@"share_btn_qq", @"share_btn_sina", @"share_btn_copylink", @"compass"]];
    
    self.actionSheet = [[SCActionSheet alloc] sc_initWithTitles:@[@"分享"] customViews:@[shareAction] buttonTitles:nil];
    shareAction.actionSheet = self.actionSheet;
    
    NSString *url = FORMAT_STRING(@"%@%@%@", MAIN_HOST, NUTZ_API_PREFIX_TOPIC, self.topicId);
     //qq
    [shareAction sc_setButtonHandler:^{
        NSArray* imageArray = @[[UIImage imageNamed:@"logo256"]];
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:tp.title
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:@"Nutz社区"
                                           type:SSDKContentTypeAuto];
        [ShareSDK share:SSDKPlatformTypeQQ parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            if(state == SSDKResponseStateSuccess){
                TOAST_SUCCESSES(@"分享成功");
                return;
            }
            if(state == SSDKResponseStateFail){
                TOAST_ERRORS(FORMAT_STRING(@"分享失败:%@",error));
                return;
            }
        }];

    } forIndex:0];
    
    //weibo
    [shareAction sc_setButtonHandler:^{
        NSString *eurl  = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *pic   = [@"http://nutzam.com/imgs/logo.png" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *title = [FORMAT_STRING(@"%@ 来自#Nutz社区#",tp.title) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *share = FORMAT_STRING(@"http://service.weibo.com/share/share.php?title=%@&url=%@&pic=%@",title,eurl,pic);
        [self openLink:[NSURL URLWithString:share]];
    } forIndex:1];
    
    //copy
    [shareAction sc_setButtonHandler:^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:url];
        TOAST_SUCCESSES(@"链接已拷贝到剪贴板");
    } forIndex:2];
    
    //open in safari
    [shareAction sc_setButtonHandler:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } forIndex:3];
    
    [self.actionSheet sc_show:YES];

}

- (BOOL)notLogin {
    if([User loginedUser]){
        return NO;
    }else{
        TOAST_INFO(@"请登录后操作");
        //[self.sideMenuViewController presentLeftMenuViewController];
        return YES;
    }
}
- (void)loadDetail:(BOOL)drag {
    int topInset = NAVBAR_HEIGHT-kRotateInsetVariable;
    refreshing = YES;
    // 刷新动画
    [self.refreshView beginRefreshing];
    if(drag){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView.scrollView setContentOffset:CGPointMake(0, -(topInset+kRefreshViewHeight)) animated:YES];
        });
    }else{
        //webview 初始inset
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(NAVBAR_HEIGHT, 0, 0, 0);
    }
    [UIView animateWithDuration:0.3 animations:^(void) {
        // 显示刷新ing
        [self.webView.scrollView setContentOffset:CGPointMake(0, -(topInset+kRefreshViewHeight)) animated:NO];
    }completion:^(BOOL complete) {
        // 持续显示刷新ing
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(topInset+kRefreshViewHeight, 0, 0, 0);
        @weakify(self);
        // 加载数据
        [[APIManager manager] topicDetailById:self.topicId callback:^(Topic *topicDtail, NSError *error) {
            @strongify(self);
            if(error){
                [self stopRefresh];
                return;
            }
            // 设置当前用户的ID
            topicDtail.curUserId = [User loginedUser].ID;
            tp = topicDtail;
            // 渲染数据
            @weakify(self);
            [self.bridge callHandler:@"renderData" data:[topicDtail toJSONString] responseCallback:^(id responseData) {
                @strongify(self);
                //渲染完成
                [UIView animateWithDuration:0.3 animations:^(void) {
                    // 恢复inset
                    self.webView.scrollView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
                    // 停止顶部刷新动画
                    [self.refreshView endRefreshing];
                    self.replyButton.alpha = 1;
                } completion:^(BOOL finished) {
                    [self stopRefresh];
                }];
            }];
            
        }];
    }];
    
}

- (void)stopRefresh{
    //渲染完成
    [UIView animateWithDuration:0.3 animations:^(void) {
        // 恢复inset
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(NAVBAR_HEIGHT-kRotateInsetVariable, 0, 0, 0);
        // 停止顶部刷新动画
        [self.refreshView endRefreshing];
    } completion:^(BOOL finished) {
        refreshing = NO;
    }];
}

- (void)setupUI {
    
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view addSubview:self.replyButton];
    
    self.refreshView = [[SCBubbleRefreshView alloc] initWithFrame:(CGRect){0, -kRefreshViewHeight, SCREEN_WIDTH, kRefreshViewHeight}];
    self.refreshView.timeOffset = 0.0;
    [self.view addSubview:self.refreshView];
    self.scrollCoordinator = [[JDFPeekabooCoordinator alloc] init];
    
    // 注册JSBridge API
    [self.bridge registerHandler:@"htmlPageLoaded" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 页面加载完成,加载话题数据
        [self loadDetail:NO];
        
        // 显示webview,以及回复按钮
        [UIView animateWithDuration:0.3 animations:^{
            self.webView.alpha     = 1;
            //self.replyButton.alpha = 1;
        }];
    }];
    
    // 点赞某条回复
    [self.bridge registerHandler:@"likeReply" handler:^(id data, WVJBResponseCallback responseCallback) {
        if([self notLogin]){
            return;
        }
        
        if([data[@"postUser"] isEqualToString:[User loginedUser].loginname]){
            TOAST_INFO(@"不能为自己点赞");
            return;
        }
        
        [[APIManager manager] likeReplyById:data[@"replyId"] accessToken:[User loginedUser].accessToken callback:^(NSString *result, NSError *error) {
            // 回调,控制点赞按钮样式
            responseCallback(@{@"result" : result, @"replyId" : data[@"replyId"]});
        }];
    }];
    
    // 用户详情
    [self.bridge registerHandler:@"goUserDetail" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self push:[UserInfoViewController userInfoWithLoginName:data]];
    }];
    
    // 回复
    savedComment = @"";
    [self.bridge registerHandler:@"replyTopic" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self replyTopic:data[@"replyId"] at:data[@"authorName"] jsCallback:responseCallback];
    }];
    
    // 加载模板页面
    NSString *path = [[NSBundle mainBundle] pathForResource:@"topic" ofType:@"html"];
    NSURL    *url  = [NSURL fileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

// 回复
- (void)replyTopic:(NSString *)replyId at:(NSString *)authorName jsCallback:(WVJBResponseCallback) responseCallback{
    if([self notLogin]){
        return;
    }
    // at某人
    if(authorName){
        savedComment = FORMAT_STRING(@"@%@ %@", authorName, savedComment);
    }
    
    [BlurCommentView showInitText:savedComment onSuccess:^(NSString *content) {
        savedComment = content;
        // 签名
        NSString *signContent = [content stringByAppendingString:TOPIC_SIGN([User userSign])];
        // 提交   
        [[APIManager manager] replyTopicById:self.topicId
                                     content:signContent
                                     replyId:replyId
                                 accessToken:[User loginedUser].accessToken
                                    callback:^(NSString *replyId, NSError *error) {
                                        if(!error){
                                            savedComment = @"";
                                            GHMarkdownParser *parser = [[GHMarkdownParser alloc] init];
                                            NSString *markdown       = [parser HTMLStringFromMarkdownString:signContent];
                                            // 构建回复对象
                                            Reply *reply             = [Reply new];
                                            reply.ID                 = replyId;
                                            reply.content            = markdown;
                                            reply.author             = [User loginedUser];
                                            reply.createAt           = [NSDate date];
                                            reply.ups                = @[];
                                            // 回调
                                            if(responseCallback){
                                                responseCallback([reply toJSONString]);
                                            }else{
                                                // js方法
                                                [self.bridge callHandler:@"addReply" data:[reply toJSONString]];
                                            }
                                        }
                                    }];
        
    } onCancel:^(NSString *commentText) {
        savedComment = commentText;
    }];
}

- (void)openLink:(NSURL *)url {
    TOWebViewController *webController = [[TOWebViewController alloc] initWithURL:url];
    UINavigationController *navController  = [[UINavigationController alloc] initWithRootViewController:webController];
    [webController setButtonTintColor:KCOLOR_MAIN_TEXT];
    [webController setShowDoneButton:NO];
    webController.applicationBarButtonItems = @[[[UIBarButtonItem alloc]
                                                 bk_initWithImage:[UIImage imageNamed:@"cancel"]
                                                 style:UIBarButtonItemStylePlain handler:^(id sender) {
                                                     [navController dismissViewControllerAnimated:YES completion:nil];
                                                 }]];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)cacheWebImage {
    
}

#pragma mark WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // 模板页面允许加载
    if([request.URL.absoluteString hasPrefix:@"file"] && [request.URL.absoluteString hasSuffix:@"topic.html"]){
        return YES;
    }
    
    // 签名链接, 不加载
    if([request.URL.absoluteString hasSuffix:@"?ios_app"]){
        return NO;
    }
    
    // 拼接站内链接host
    NSURL *url;
    if([request.URL.absoluteString hasPrefix:@"file"]){
        url = [NSURL URLWithString:FORMAT_STRING(@"%@%@", MAIN_HOST, request.URL.path)];
    }else{
        url = request.URL;
    }
    
    //帖子
    NSString *prefix = [NSString stringWithFormat:@"%@%@",MAIN_HOST, NUTZ_API_PREFIX_TOPIC];
    NSString *prefixs = [NSString stringWithFormat:@"%@%@",MAIN_HOST_HTTPS, NUTZ_API_PREFIX_TOPIC];
    if([[url absoluteString] hasPrefix:prefix] || [ [url absoluteString] hasPrefix:prefixs]){
        NSString *topicId = [request.URL.absoluteString componentsSeparatedByString:@"/"].lastObject;
        TopicDetailViewController *topicVC = [[TopicDetailViewController alloc] init];
        topicVC.topicId = topicId;
        [self.navigationController pushViewController:topicVC animated:YES];
        return NO;
    }
    
    
    // 浏览器
    [self openLink:url];
    
    return NO;
}

#pragma mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Refresh
    CGFloat offsetY             = -(scrollView.contentOffset.y + NAVBAR_HEIGHT);
    CGRect frame                = self.refreshView.frame;
    frame.origin.y              = -kRefreshViewHeight - scrollView.contentOffset.y;
    self.refreshView.frame      = frame;
    self.refreshView.timeOffset = MAX(offsetY / NAVBAR_HEIGHT, 0);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y <= -44-NAVBAR_HEIGHT && !refreshing) {
        [self loadDetail:YES];
    }
}

#pragma mark Getter
- (WebViewJavascriptBridge *)bridge {
    if(!_bridge){
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"JSLog: %@", data);
        }];
    }
    return _bridge;
}

- (UIWebView *)webView {
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        _webView.opaque = NO;
        _webView.alpha = 0;
        _webView.backgroundColor = KCOLOR_BG_COLOR;
        _webView.scrollView.delegate = self;
        _webView.scrollView.contentInset = UIEdgeInsetsMake(-kRefreshViewHeight, 0, 0, 0);
    }
    return _webView;
}

- (LGPlusButtonsView *)replyButton {
    if(!_replyButton){
        _replyButton = [[LGPlusButtonsView alloc] initWithNumberOfButtons:1 firstButtonIsPlusButton:YES showAfterInit:YES actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index) {
            // 添加回复
            [self replyTopic:@"" at:nil jsCallback:nil];
        }];
        _replyButton.observedScrollView = self.webView.scrollView;
        [_replyButton setButtonsTitles:@[@"\uf112"] forState:UIControlStateNormal];
        [_replyButton setButtonsBackgroundColor:KCOLOR_MAIN_BLUE forState:UIControlStateNormal];
        [_replyButton setButtonsSize:CGSizeMake(60.f, 60.f) forOrientation:LGPlusButtonsViewOrientationAll];
        [_replyButton setButtonsLayerCornerRadius:60.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
        [_replyButton setButtonsTitleFont:[UIFont fontWithName:FONT_ICONS size:24.f] forOrientation:LGPlusButtonsViewOrientationAll];
        //[_replyButton setButtonsLayerShadowOpacity:0.5];
        //[_replyButton setButtonsLayerShadowRadius:2.f];
        //[_replyButton setButtonsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
        [_replyButton setAlpha:0];
    }
    return  _replyButton;
}

@end
