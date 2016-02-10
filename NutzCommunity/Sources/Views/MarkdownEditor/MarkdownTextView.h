//
//  MarkdownTextView.h
//  NutzCommunity
//  修改自coding
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface MarkdownTextView : UIPlaceHolderTextView<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
//正在选择图片
@property (assign, nonatomic) BOOL pickingPhoto;
@end
