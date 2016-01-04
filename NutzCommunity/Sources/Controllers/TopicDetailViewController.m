//
//  TopicDetailViewController.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/23.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "TopicDetailViewController.h"
#import "WebViewJavascriptBridge.h"

@interface TopicDetailViewController ()<UIWebViewDelegate> {
    // 页面是否加载完成
    BOOL pageLoaded;
}

@property (nonatomic, strong)  WebViewJavascriptBridge* bridge;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation TopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Detail";
    self.view.backgroundColor = COLOR_WHITE;
    
    pageLoaded = NO;
    [self setupViews];
    [self loadDetail];
}

- (void)loadDetail {
    @weakify(self);
    [[APIManager manager] topicDetailById:self.topic.id callback:^(Topic *topicDtail, NSError *error) {
        @strongify(self);
        self.topic = topicDtail;
        while(!pageLoaded) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        NSLog(@"render");
        [self.bridge callHandler:@"renderData" data:[topicDtail toJSONString]];
    }];
}

- (void)setupViews {
    [self.view addSubview:self.webView];
    // 注册JSBridge API
    [self.bridge registerHandler:@"htmlPageLoaded" handler:^(id data, WVJBResponseCallback responseCallback) {
        //页面加载完成
        pageLoaded = YES;
    }];
    // 点赞
    [self.bridge registerHandler:@"likeReply" handler:^(id data, WVJBResponseCallback responseCallback) {
        //data: {"postUser" : postUser, "replyId" : replyId}
        DEBUG_LOG(@"user: %@, id: %@", data[@"postUser"], data[@"replyId"]);
        [[APIManager manager] likeReplyById:data[@"replyId"] accessToken:[User loginedUser].accessToken callback:^(NSString *likeType, NSError *error) {
            responseCallback(likeType);
        }];
    }];
    
    // 加载模板页面
    NSString* path = [[NSBundle mainBundle] pathForResource:@"topic" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
        _webView.backgroundColor = COLOR_WHITE;
    }
    return _webView;
}

@end
