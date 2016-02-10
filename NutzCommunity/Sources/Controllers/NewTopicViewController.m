//
//  添加新的话题
//  NewTopicViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/11.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "NewTopicViewController.h"
#import "MarkdownTextView.h"
#import <GHMarkdownParser/GHMarkdownParser.h>
#import "KxMenu.h"

#define kPaddingLeftWidth 10
#define kTitleTextHeight  30

@interface NewTopicViewController ()<UIWebViewDelegate>{
    BOOL     templateLoaded;
    NSString *selectedTab;
}

@property (assign, nonatomic) NSInteger curIndex;
@property (strong, nonatomic) UIWebView *preview;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) MarkdownTextView *editView;
@property (strong, nonatomic) UITextField *titleText;
@property (strong, nonatomic) UIButton *tabType;
@property (strong, nonatomic) Topic *sendData;

@end

@implementation NewTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = KCOLOR_WHITE;
    // 编辑界面
    self.containerView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.containerView];
    
    // 分段按钮
    self.navigationItem.titleView = self.segmentedControl;
    // 保存按钮
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ok"] style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClicked)];
    [self.navigationItem setRightBarButtonItem:saveItem animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // 返回按钮
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClicked)];
    [self.navigationItem setLeftBarButtonItem:cancelItem animated:YES];
    
    // 加载草稿
    self.sendData = [Topic loadTopic];
    if(!self.sendData){
        self.sendData = [Topic new];
    }
    
    // 默认显示editText
    self.curIndex = 0;
    
    // 控制edit尺寸
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        if (self.editView) {
            NSDictionary* userInfo = [aNotification userInfo];
            CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            self.editView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(keyboardEndFrame), 0);
            self.editView.scrollIndicatorInsets = self.editView.contentInset;
        }
    }];
    
    // 标题聚焦
    [self.titleText becomeFirstResponder];
}

#pragma mark Actions
- (void)saveBtnClicked {
    if(TRIM_STRING(self.titleText.text).length < 10){
        TOAST_INFO(@"标题至少10个字");
        return;
    }
    
    //组装数据
    self.sendData.content  = [self.editView.text stringByAppendingFormat:@"\n\n%@", TOPIC_SIGN([User userSign])];
    self.sendData.title    = self.titleText.text;
    self.sendData.tab      = selectedTab;
    self.sendData.author   = [User loginedUser];
    self.sendData.createAt = [NSDate date];
    
    if(![self.tabTypeKey isEqualToString:selectedTab]){
        [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"您当前浏览的板块与发帖的板块不一致" cancelButtonTitle:@"取消发帖" otherButtonTitles:@[@"确认发帖"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex == 0){
                return;
            }else{
                if(self.sendTopic){
                    // 保存草稿
                    [self.sendData saveTopic];
                    _sendTopic(self.sendData);
                }
                [self dismissModal];
            }
        }];
    }else{
        if(self.sendTopic){
            // 保存草稿
            [self.sendData saveTopic];
            _sendTopic(self.sendData);
        }
        [self dismissModal];
    }
    
}

- (void)cancelBtnClicked {
    NSString *title   = TRIM_STRING(self.titleText.text);
    NSString *content = TRIM_STRING(self.editView.text);
    
    // 存草稿
    if(title.length != 0 || content.length != 0){
        __weak typeof(self) weakSelf = self;
        [self.titleText resignFirstResponder];
        [self.editView resignFirstResponder];
        [[UIActionSheet bk_actionSheetCustomWithTitle:@"是否保存草稿"
                                         buttonTitles:@[@"保存"]
                                     destructiveTitle:@"不保存"
                                          cancelTitle:@"取消"
                                   andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            //保存
            if (index == 0) {
                weakSelf.sendData.title   = title;
                weakSelf.sendData.tab     = selectedTab;
                weakSelf.sendData.content = content;
                [weakSelf.sendData saveTopic];
            }else if (index == 1){
                [Topic delTopic];
            }else{
                return ;
            }
            [weakSelf dismissModal];
        }] showInView:self.view];
    }else{
        [self dismissModal];
    }
}

- (void)segmentedControlSelected:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.curIndex = segmentedControl.selectedSegmentIndex;
}

// 加载编辑界面
- (void)loadEditView {
    self.containerView.hidden = NO;
    self.preview.hidden       = YES;
    [self.editView becomeFirstResponder];
}

// 加载预览界面
- (void)loadPreview {
    self.preview.hidden       = NO;
    self.containerView.hidden = YES;
    [self.editView resignFirstResponder];
    [self.titleText resignFirstResponder];
    
    [_activityIndicator startAnimating];

    if(templateLoaded){
        [self renderPreview];
        return;
    }
    
    // 加载HTML模板页面
    NSString* path = [[NSBundle mainBundle] pathForResource:@"topic" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    [self.preview loadRequest:[NSURLRequest requestWithURL:url]];
}

// 弹出板块选择菜单
- (void)showMenu:(UIButton *)sender {
    NSDictionary *tabTypes = [Topic tabTypes];
    NSArray *keys = [tabTypes allKeys];
    NSMutableArray *menus = [[NSMutableArray alloc] initWithCapacity:keys.count];
    for(NSString *key in keys){
        NSString *title = [tabTypes objectForKey:key];
        KxMenuItem *menu = [KxMenuItem menuItem:title
                                            key:key
                                          image:nil
                                         target:self
                                         action:@selector(clickedTabTypeItem:)];
        [menus addObject:menu];
    }
    
    //解决键盘遮盖问题
    [KxMenu showMenuInView:LAST_WINDOW
                  fromRect:sender.frame
                 menuItems:menus];
}

- (void) clickedTabTypeItem:(KxMenuItem *)sender {
    [self.tabType setTitle:sender.title forState:UIControlStateNormal];
    selectedTab = sender.key;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // 只允许加载模板页面
    if([[[request URL] absoluteString] hasSuffix:@"topic.html"]){
        return YES;
    }
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    templateLoaded = YES;
    [self renderPreview];
}

- (void)renderPreview {
    // 转换markdown
    GHMarkdownParser *parser = [[GHMarkdownParser alloc] init];
    parser.options = kGHMarkdownAutoLink; // for example
    parser.githubFlavored = YES;
    parser.baseURL = [NSURL URLWithString:MAIN_HOST];
    NSString *sign = TOPIC_SIGN([User userSign]);
    NSString *htmlString = [parser HTMLStringFromMarkdownString:
                            [self.editView.text stringByAppendingFormat:@"\n\n%@", sign]];
    
    // 新建模型
    self.sendData.title    = self.titleText.text;
    self.sendData.tab      = selectedTab;
    self.sendData.content  = htmlString;
    self.sendData.author   = [User loginedUser];
    self.sendData.createAt = [NSDate date];
    
    // 加载预览数据
    [self.preview stringByEvaluatingJavaScriptFromString:FORMAT_STRING(@"renderData(%@);", [self.sendData toJSONString])];
    [_activityIndicator stopAnimating];
}

- (void)dismissModal {
    [self.editView  resignFirstResponder];
    [self.titleText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Setter 切换视图
- (void)setCurIndex:(NSInteger)curIndex{
    _curIndex = curIndex;
    if (self.segmentedControl.selectedSegmentIndex != curIndex) {
        [_segmentedControl setSelectedSegmentIndex:_curIndex];
    }

    if (_curIndex == 0) {
        [self loadEditView];
    }else{
        [self loadPreview];
    }
}

#pragma mark Getter
// 分节开关
- (UISegmentedControl *)segmentedControl  {
    if (!_segmentedControl) {
        _segmentedControl = ({
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"编辑", @"预览"]];
            [segmentedControl setWidth:80 forSegmentAtIndex:0];
            [segmentedControl setWidth:80 forSegmentAtIndex:1];
            [segmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName: KCOLOR_MAIN_BLUE}
                                            forState:UIControlStateNormal];
            [segmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                       NSForegroundColorAttributeName : [UIColor whiteColor]}
                                            forState:UIControlStateSelected];
            [segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
            
            segmentedControl;
        });
    }
    return _segmentedControl;
}

// 板块选择按钮
- (UIButton *)tabType{
    if(!_tabType){
        _tabType                      = [UIButton buttonWithType:UIButtonTypeCustom];
        _tabType.titleLabel.font      = [UIFont fontWithName:FONT_DEFAULE_BOLD size:18];
        [_tabType setImage:[UIImage imageNamed:@"split_line"] forState:UIControlStateNormal];
        [_tabType setTitleColor:KCOLOR_MAIN_BLUE forState:UIControlStateNormal];
        [_tabType addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        if(self.sendData.tab){
            selectedTab = self.sendData.tab;
        }
        [_tabType setTitle:[Topic tabTypeName:selectedTab] forState:UIControlStateNormal];
        
        _tabType.imageEdgeInsets = UIEdgeInsetsMake(0.0, -25, 0.0, 0.0);
        _tabType.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        [self.containerView addSubview:_tabType];
    }
    return _tabType;
}

// 话题标题输入框
- (UITextField *)titleText{
    if(!_titleText){
        _titleText             = [[UITextField alloc] initWithFrame:CGRectZero];
        _titleText.font        = [UIFont fontWithName:FONT_DEFAULE_BOLD size:18];
        _titleText.placeholder = @"标题,一句话概括主题内容";
        _titleText.text        = self.sendData.title;
        
        [self.containerView addSubview:_titleText];
        [self.titleText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView).offset(NAVBAR_HEIGHT + 10);
            make.height.mas_equalTo(kTitleTextHeight);
            make.left.equalTo(self.containerView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.tabType.mas_left).offset(-kPaddingLeftWidth);
        }];
        
        // 提问板块按钮
        [self.tabType mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleText);
            make.bottom.equalTo(_titleText);
            make.right.equalTo(self.containerView);
            make.width.mas_equalTo(80);
        }];
    }
    return _titleText;
}

// 话题内容
- (MarkdownTextView *)editView {
    if (!_editView) {
        _editView                    = [[MarkdownTextView alloc] initWithFrame:self.containerView.bounds];
        _editView.backgroundColor    = [UIColor clearColor];
        _editView.font               = [UIFont systemFontOfSize:16];
        _editView.textContainerInset = UIEdgeInsetsMake(5, kPaddingLeftWidth - 5, 8, kPaddingLeftWidth - 5);
        _editView.placeholder        = @"请完整描述问题";
        _editView.text               = self.sendData.content;
        
        float space = 8;
        
        UIView *_lineView = [UIView new];
        _lineView.backgroundColor = KCOLOR_LIGHT_GRAY;
        [self.containerView addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleText.mas_bottom).offset(space);
            make.left.equalTo(self.containerView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(0.5);
            make.right.equalTo(self.containerView);
        }];
        
        [self.containerView addSubview:_editView];
        [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_lineView).offset(space);
            make.left.equalTo(self.containerView);
            make.right.equalTo(self.containerView);
            make.bottom.equalTo(self.containerView);
        }];
        
        // 无内容不可保存
        RAC(self.navigationItem.rightBarButtonItem, enabled)
        = [RACSignal combineLatest:@[_editView.rac_textSignal]
                                reduce:^(NSString *mdStr){
                                    return @(TRIM_STRING(mdStr).length > 0);
                                }];
        
    }
    return _editView;
}

// 预览webview
- (UIWebView *)preview {
    if (!_preview) {
        _preview                 = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _preview.delegate        = self;
        _preview.backgroundColor = [UIColor whiteColor];
        _preview.opaque          = NO;
        _preview.scalesPageToFit = YES;
        
        //webview加载指示
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [_preview addSubview:_activityIndicator];
        [self.view addSubview:_preview];
        
        [_preview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        _preview.scrollView.contentInset = UIEdgeInsetsMake(NAVBAR_HEIGHT, 0, 0, 0);
        [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_preview);
        }];
    }
    return _preview;
}

#pragma mark setter
- (void)setTabTypeKey:(NSString *)tabTypeKey {
    _tabTypeKey = tabTypeKey;
    //默认板块
    selectedTab = tabTypeKey;
}

@end
