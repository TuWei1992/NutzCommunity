//
//  TopicTableViewCell.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/23.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h"

@interface TopicTableViewCell : UITableViewCell

// 分类
@property (weak, nonatomic) IBOutlet UILabel *category;
// 话题标题
@property (weak, nonatomic) IBOutlet UILabel *topicTitle;
// 用户昵称
@property (weak, nonatomic) IBOutlet UILabel *nickname;
// 最后发表于
@property (weak, nonatomic) IBOutlet UILabel *lastPost;
// 发布时间
@property (weak, nonatomic) IBOutlet UILabel *publishTime;
// 回复/浏览数
@property (weak, nonatomic) IBOutlet UILabel *counts;
// 用户头像
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
// 精华
@property (weak, nonatomic) IBOutlet UIImageView *jinghua;

// model
@property (nonatomic, strong) Topic *topic;

@end
