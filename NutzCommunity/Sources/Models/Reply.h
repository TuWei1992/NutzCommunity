//
//  Reply.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/27.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "BaseModel.h"

@protocol Reply @end

@interface Reply : BaseModel

@property (nonatomic, assign) int id;
@property (nonatomic, strong) User *author;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSArray *ups;
// ("create_at")
@property (nonatomic, strong) NSDate *createAt;

@end
