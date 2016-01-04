//
//  基础模型, 提供序列化方法
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface BaseModel : JSONModel

- (instancetype)initWithDictionary:(NSDictionary *)dict;


@end
