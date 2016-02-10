//
//  AppSignTableViewCell.h
//  NutzCommunity
//
//  Created by DuWei on 16/1/31.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSignTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *loginname;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *sign;

@end
