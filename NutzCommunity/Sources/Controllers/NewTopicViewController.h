//
//  添加新的话题
//  NewTopicViewController.m
//  NutzCommunity
//
//  Created by DuWei on 16/1/11.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTopicViewController : BaseViewController

// 板块的key
@property (strong,nonatomic) NSString               *tabTypeKey;
@property (copy, nonatomic)  void(^sendTopic) (Topic *sendData);

@end
