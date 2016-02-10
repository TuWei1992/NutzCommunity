//
//  MarkdownTextView.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "MarkdownTextView.h"
#import "RFKeyboardToolbar.h"
#import "RFToolbarButton.h"
#import <RegexKitLite/RegexKitLite.h>
#import "NSDate+Utilities.h"
//photo
#import <MBProgressHUD/MBProgressHUD.h>

@interface MarkdownTextView ()
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) NSString *uploadingPhotoName;
@end


@implementation MarkdownTextView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.inputAccessoryView = [RFKeyboardToolbar toolbarWithButtons:[self buttons]];
        
    }
    return self;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    NSString *actionName = NSStringFromSelector(action);
    if ([actionName isEqualToString:@"_addShortcut:"]) {
        return NO;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}

- (NSArray *)buttons {
    return @[

             [self createButtonWithTitle:@"( )" andEventHandler:^{
                 [self insertText:@"( )"];
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location -= 2;
                 selectionRange.length = 1;
                 [self setSelectionRange:selectionRange];
             }],
             [self createButtonWithTitle:@"{ }" andEventHandler:^{
                 [self insertText:@"{ }"];
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location -= 2;
                 selectionRange.length = 1;
                 [self setSelectionRange:selectionRange];
             }],
             [self createButtonWithTitle:@"[ ]" andEventHandler:^{
                 [self insertText:@"[ ]"];
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location -= 2;
                 selectionRange.length = 1;
                 [self setSelectionRange:selectionRange];
             }],
             
             [self createButtonWithTitle:@"=" andEventHandler:^{ [self insertText:@"="]; }],
             [self createButtonWithTitle:@";" andEventHandler:^{ [self insertText:@";"]; }],
             [self createButtonWithTitle:@"Tab" andEventHandler:^{ [self insertText:@"\t"]; }],
             [self createButtonWithTitle:@"`" andEventHandler:^{ [self insertText:@"`"]; }],
             
             // 代码
             [self createButtonWithTitle:@"\uf121" andEventHandler:^{ [self doCode]; }],
             
             // 图片
             [self createButtonWithTitle:@"\uf1c5" andEventHandler:^{ [self doPhoto]; }],
             
             // 标题
             [self createButtonWithTitle:@"\uf1dc" andEventHandler:^{ [self doTitle]; }],
             
             // 粗体
             [self createButtonWithTitle:@"\uf032" andEventHandler:^{ [self doBold]; }],
             
             // 斜体
             [self createButtonWithTitle:@"\uf033" andEventHandler:^{ [self doItalic]; }],
             
             // 引用
             [self createButtonWithTitle:@"\uf10d" andEventHandler:^{ [self doQuote]; }],
             
             // 列表
             [self createButtonWithTitle:@"\uf0ca" andEventHandler:^{ [self doList]; }],
             
             // 链接
             [self createButtonWithTitle:@"\uf0c1" andEventHandler:^{
                 NSString *tipStr = @"在此输入链接地址";
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 5;
                 selectionRange.length = tipStr.length;

                 [self insertText:[NSString stringWithFormat:@"[链接](%@)", tipStr]];
                 [self setSelectionRange:selectionRange];
             }],
             
             // 图片链接
             [self createButtonWithTitle:@"\uf03e" andEventHandler:^{
                 NSString *tipStr = @"在此输入图片地址";
                 NSRange selectionRange = self.selectedRange;
                 selectionRange.location += 6;
                 selectionRange.length = tipStr.length;

                 [self insertText:[NSString stringWithFormat:@"![图片](%@)", tipStr]];
                 [self setSelectionRange:selectionRange];
             }],
             
             //分割线
             [self createButtonWithTitle:@"\uf068" andEventHandler:^{
                 NSRange selectionRange = self.selectedRange;
                 NSString *insertStr = [self needPreNewLine]? @"\n\n------\n\n": @"\n------\n\n";
                 
                 selectionRange.location += insertStr.length;
                 selectionRange.length = 0;
                 
                 [self insertText:insertStr];
                 [self setSelectionRange:selectionRange];
             }]
             ];
}

- (BOOL)needPreNewLine{
    NSString *preStr = [self.text substringToIndex:self.selectedRange.location];
    return !(preStr.length == 0
            || [preStr isMatchedByRegex:@"[\\n\\r]+[\\t\\f]*$"]);
}

- (RFToolbarButton *)createButtonWithTitle:(NSString*)title andEventHandler:(void(^)())handler {
    RFToolbarButton *btn = [RFToolbarButton buttonWithTitle:title andEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:[UIFont fontWithName:FONT_ICONS size:18]];
    [btn setTitleColor:KCOLOR_MAIN_BLUE forState:UIControlStateNormal];
    [btn setBackgroundColor:KCOLOR_CLEAR];

    return btn;
}

- (void)setSelectionRange:(NSRange)range {
    UIColor *previousTint = self.tintColor;
    
    self.tintColor = UIColor.clearColor;
    self.selectedRange = range;
    self.tintColor = previousTint;
}

#pragma mark md_Method
- (void)doTitle{
    [self doMDWithLeftStr:@"## " rightStr:@" " tipStr:@"在此输入标题" doNeedPreNewLine:YES];
}

- (void)doBold{
    [self doMDWithLeftStr:@"**" rightStr:@"**" tipStr:@"在此输入粗体文字" doNeedPreNewLine:NO];
}

- (void)doItalic{
    [self doMDWithLeftStr:@"*" rightStr:@"*" tipStr:@"在此输入斜体文字" doNeedPreNewLine:NO];
}

- (void)doCode{
    [self doMDWithLeftStr:@"```\n" rightStr:@"\n```" tipStr:@"在此输入代码片段" doNeedPreNewLine:YES];
}

- (void)doQuote{
    [self doMDWithLeftStr:@"> " rightStr:@"" tipStr:@"在此输入引用文字" doNeedPreNewLine:YES];
}

- (void)doList{
    [self doMDWithLeftStr:@"- " rightStr:@"" tipStr:@"在此输入列表项" doNeedPreNewLine:YES];
}

- (void)doMDWithLeftStr:(NSString *)leftStr rightStr:(NSString *)rightStr tipStr:(NSString *)tipStr doNeedPreNewLine:(BOOL)doNeedPreNewLine{
    
    BOOL needPreNewLine = doNeedPreNewLine? [self needPreNewLine]: NO;
    
    
    if (!leftStr || !rightStr || !tipStr) {
        return;
    }
    NSRange selectionRange = self.selectedRange;
    NSString *insertStr = [self.text substringWithRange:selectionRange];
    
    if (selectionRange.length > 0) {//已有选中文字
        //撤销
        if (selectionRange.location >= leftStr.length && selectionRange.location + selectionRange.length + rightStr.length <= self.text.length) {
            NSRange expandRange = NSMakeRange(selectionRange.location- leftStr.length, selectionRange.length +leftStr.length +rightStr.length);
            expandRange = [self.text rangeOfString:[NSString stringWithFormat:@"%@%@%@", leftStr, insertStr, rightStr] options:NSLiteralSearch range:expandRange];
            if (expandRange.location != NSNotFound) {
                selectionRange.location -= leftStr.length;
                selectionRange.length = insertStr.length;
                [self setSelectionRange:expandRange];
                [self insertText:insertStr];
                [self setSelectionRange:selectionRange];
                return;
            }
        }
        //添加
        selectionRange.location += needPreNewLine? leftStr.length +1: leftStr.length;
        insertStr = [NSString stringWithFormat:needPreNewLine? @"\n%@%@%@": @"%@%@%@", leftStr, insertStr, rightStr];
    }else{//未选中任何文字
        //添加
        selectionRange.location += needPreNewLine? leftStr.length +1: leftStr.length;
        selectionRange.length = tipStr.length;
        insertStr = [NSString stringWithFormat:needPreNewLine? @"\n%@%@%@": @"%@%@%@", leftStr, tipStr, rightStr];
    }
    [self insertText:insertStr];
    [self setSelectionRange:selectionRange];
}

#pragma mark Photo
- (void)doPhoto{
    // 选择图片
    self.pickingPhoto = YES;
    // 将从相册选取返回
    dispatch_async(dispatch_get_main_queue(), ^{
        //跳转代码
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = (id)self;
        picker.view.backgroundColor = [UIColor whiteColor];
        //设置选择后的图片可被编辑
        //picker.allowsEditing = YES;
        
        [[BaseViewController presentingVC] presentViewController:picker animated:YES completion:nil];
    });
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && originalImage) {
        UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
    }

    //上传照片
    [picker dismissViewControllerAnimated:YES completion:^{
        if (originalImage) {
            [self doUploadPhoto:originalImage];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    self.pickingPhoto = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self becomeFirstResponder];
}

// 压缩图片
- (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

- (void)doUploadPhoto:(UIImage *)image{
    //压缩图片
    //UIImage *cmpImage = [self compressImage:image toMaxFileSize:(1024*1024)];
    [self hudTipWillShow:YES];
    [[APIManager manager] uploadImage:image accessToken:[User loginedUser].accessToken
                             callback:^(NSString *imageUrl, NSError *error) {
                                 [self hudTipWillShow:NO];
                                 if(!error){
                                     [self completionUploadWithResult:imageUrl];
                                 }
                                 [self becomeFirstResponder];
                             } progerss:^(CGFloat progressValue) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (self.HUD) {
                                         [self.HUD setProgress:progressValue];
                                     }
                                 });
                             }];
}

- (void)completionUploadWithResult:(NSString*)imageUrl{
    self.pickingPhoto = NO;
    //插入文字
    NSString *fileUrlStr = imageUrl;
    NSString *photoLinkStr = [NSString stringWithFormat:[self needPreNewLine]? @"\n![图片](%@)\n": @"![图片](%@)\n", fileUrlStr];
    [self insertText:photoLinkStr];
    [self becomeFirstResponder];
}

- (void)hudTipWillShow:(BOOL)willShow{
    if (willShow) {
        [self resignFirstResponder];
        if (!_HUD) {
            _HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            _HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
            _HUD.labelText = @"正在上传图片...";
            _HUD.removeFromSuperViewOnHide = YES;
        }else{
            _HUD.progress = 0;
            [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
            [_HUD show:YES];
        }
    }else{
        [_HUD hide:YES];
    }
}

@end
