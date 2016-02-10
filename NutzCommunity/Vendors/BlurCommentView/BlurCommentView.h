//
//  JSGCommentView.h
//  blur_comment
//
//  Created by dai.fengyi on 15/5/15.
//  Copyright (c) 2015年 childrenOurFuture. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BlurCommentViewDelegate <NSObject>
@optional
- (void)commentDidFinished:(NSString *)commentText;
@end
typedef void(^SuccessBlock)(NSString *commentText);
typedef void(^CancelBlock)(NSString *commentText);
@interface BlurCommentView : UIImageView
//
+ (void)commentShowInView:(UIView *)view success:(SuccessBlock)success;
+ (void)commentShowInView:(UIView *)view delegate:(id <BlurCommentViewDelegate>)delegate;

//default is in [UIApplication sharedApplication].keyWindow
+ (void)commentShowSuccess:(SuccessBlock)success;
+ (instancetype)showInitText:(NSString *)text onSuccess:(SuccessBlock)success onCancel:(CancelBlock)cancel;
+ (void)commentShowDelegate:(id <BlurCommentViewDelegate>)delegate;
@end
