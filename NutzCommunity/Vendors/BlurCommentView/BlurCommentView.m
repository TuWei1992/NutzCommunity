//
//  JSGCommentView.m
//  blur_comment
//
//  Created by dai.fengyi on 15/5/15.
//  Copyright (c) 2015年 childrenOurFuture. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BlurCommentView.h"
#import "UIImageEffects.h"
#import "UIView+Common.h"
#import "MarkdownTextView.h"

#define ANIMATE_DURATION    0.3f
#define kMarginWH           8
#define kButtonWidth        60
#define kButtonHeight       27
#define IS_LANDSPACE        UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)
#define kTextFont           [UIFont fontWithName:FONT_DEFAULE size:15]
#define kTextViewHeight     ((IS_IPHONE4S || IS_IPHONE5S) ? (IS_LANDSPACE ? 45:118) : 120)
#define kSheetViewHeight    (kMarginWH * 3 + kButtonHeight + kTextViewHeight)
#define kSheetBgColor       [UIColor colorWithWhite:0.970 alpha:1.000]
@interface BlurCommentView ()<UITextViewDelegate>{
    //评论按钮
    UIButton *commentButton;
}
@property (copy, nonatomic) SuccessBlock success;
@property (copy, nonatomic) CancelBlock  cancel;
@property (weak, nonatomic) id<BlurCommentViewDelegate> delegate;
@property (strong, nonatomic) UIView *sheetView;
@property (strong, nonatomic) MarkdownTextView *commentTextView;
@end
@implementation BlurCommentView
+ (instancetype)commentShowInView:(UIView *)view success:(SuccessBlock)success delegate:(id <BlurCommentViewDelegate>)delegate {
    BlurCommentView *commentView = [[BlurCommentView alloc] initWithFrame:view.bounds];
    if (commentView) {
        //挡住响应
        commentView.userInteractionEnabled = YES;
        //block or delegate
        commentView.success                = success;
        commentView.delegate               = delegate;
        //截图并虚化
        commentView.image                  = [UIImageEffects imageByApplyingLightEffectToImage:[commentView snapShot:view]];
        //增加EventResponsor
        [commentView addEventResponsors];
        
        [view addSubview:commentView];
        [view addSubview:commentView.sheetView];
        [commentView.commentTextView becomeFirstResponder];
    }
    return commentView;
}
#pragma mark - 外部调用
+ (instancetype)showInitText:(NSString *)text onSuccess:(SuccessBlock)success onCancel:(CancelBlock)cancel {
    BlurCommentView *comm = [BlurCommentView commentShowInView:[UIApplication sharedApplication].keyWindow success:success delegate:nil];
    comm.commentTextView.text = text;
    comm.cancel = cancel;
    return comm;
}
+ (void)commentShowSuccess:(SuccessBlock)success {
    [BlurCommentView commentShowInView:[UIApplication sharedApplication].keyWindow success:success delegate:nil];
}

+ (void)commentShowDelegate:(id<BlurCommentViewDelegate>)delegate {
    [BlurCommentView commentShowInView:[UIApplication sharedApplication].keyWindow success:nil delegate:delegate];
}

+ (void)commentShowInView:(UIView *)view success:(SuccessBlock)success {
    [BlurCommentView commentShowInView:view success:success delegate:nil];
}

+ (void)commentShowInView:(UIView *)view delegate:(id<BlurCommentViewDelegate>)delegate {
    [BlurCommentView commentShowInView:view success:nil delegate:delegate];
}
#pragma mark - 内部调用
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    self.alpha = 0;

    CGRect rect                = self.bounds;
    _sheetView                 = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - kSheetViewHeight, rect.size.width, kSheetViewHeight)];
    _sheetView.backgroundColor = kSheetBgColor;
// 用了阴影6p会掉帧
//    _sheetView.layer.shadowOpacity = 0.1;
//    _sheetView.layer.shadowColor = KCOLOR_BLACK.CGColor;
//    _sheetView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    [_sheetView addTopLineWidthLeftSpace:0];
    
    UIButton *cancelButton         = [UIButton buttonWithType:UIButtonTypeCustom];
     cancelButton.frame            = CGRectMake(kMarginWH, kMarginWH, kButtonWidth, kButtonHeight);
     cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
     cancelButton.titleLabel.font  = kTextFont;
    
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:  KCOLOR_MAIN_TEXT                 forState:UIControlStateNormal];
    [cancelButton addTarget:self  action:@selector(cancelComment:) forControlEvents:UIControlEventTouchUpInside];
    [_sheetView   addSubview: cancelButton];
    
    commentButton                  = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame            = CGRectMake(_sheetView.bounds.size.width - kButtonWidth - kMarginWH, kMarginWH, kButtonWidth, kButtonHeight);
    commentButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    commentButton.titleLabel.font  = kTextFont;
    commentButton.enabled          = NO;
    
    [commentButton setTitle:@"发送"                              forState: UIControlStateNormal];
    [commentButton setTitleColor:  KCOLOR_MAIN_TEXT             forState:UIControlStateNormal];
    [commentButton setTitleColor:  [UIColor lightGrayColor]     forState:UIControlStateDisabled];
    [commentButton addTarget:self  action:@selector(comment:)   forControlEvents:UIControlEventTouchUpInside];
    [_sheetView    addSubview:     commentButton];
    
    
    UILabel *label                     = [[UILabel alloc] init];
    label.text                         = @"回复评论";
    label.frame                        = CGRectMake((_sheetView.bounds.size.width - kButtonWidth-20) / 2, kMarginWH, kButtonWidth+20, kButtonHeight);
    label.font                         = [UIFont boldSystemFontOfSize:18];
    label.textColor                    = KCOLOR_MAIN_BLUE;
    label.autoresizingMask             = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_sheetView addSubview:label];

    _commentTextView                   = [[MarkdownTextView alloc] initWithFrame:CGRectMake(kMarginWH,
                                                                                      _sheetView.bounds.size.height - kMarginWH - kTextViewHeight,
                                                                                      rect.size.width - kMarginWH * 2,
                                                                                            kTextViewHeight)];
    _commentTextView.text              = nil;
    [_sheetView addSubview:_commentTextView];
    _commentTextView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.000].CGColor;
    _commentTextView.layer.borderWidth = 0.5;
    _commentTextView.font              = kTextFont;
    _commentTextView.delegate          = self;
    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(cancelComment:)];
    [self addGestureRecognizer:tap];
}

// 屏幕快照
- (UIImage *)snapShot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0f);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 监听通知
- (void)addEventResponsors {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if(textView == _commentTextView){
        if([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
            commentButton.enabled = YES;
        }else{
            commentButton.enabled = NO;
        }
    }
}

#pragma mark - Botton Action
- (void)cancelComment:(id)sender {
    [_sheetView endEditing:YES];
}

- (void)comment:(id)sender {
    //发送请求
    if (_success) {
        _success(_commentTextView.text);
    }
    if ([_delegate respondsToSelector:@selector(commentDidFinished:)]) {
        [_delegate commentDidFinished:_commentTextView.text];
    }
    [_sheetView endEditing:YES];
}

- (void)dismissCommentView {
    if(_cancel){
        _cancel(_commentTextView.text);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
    [_sheetView removeFromSuperview];
    self.image = nil;
    _commentTextView = nil;
    _sheetView = nil;
}

#pragma mark - Keyboard Notification Action
- (void)keyboardWillShow:(NSNotification *)aNotification {
    CGFloat           keyboardHeight = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval animationDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 显示评论框
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = 1;
        _sheetView.frame = CGRectMake(0,
                                      self.superview.bounds.size.height - _sheetView.bounds.size.height - keyboardHeight,
                                      _sheetView.bounds.size.width,
                                      kSheetViewHeight);
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSDictionary           *userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 隐藏评论框
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = 0;
        _sheetView.frame = CGRectMake(0,
                                      self.superview.bounds.size.height,
                                      _sheetView.bounds.size.width,
                                      kSheetViewHeight);
    } completion:^(BOOL finished){
        // 不是上传图片
        if(!self.commentTextView.pickingPhoto){
            [self dismissCommentView];
        }
    }];
}
@end