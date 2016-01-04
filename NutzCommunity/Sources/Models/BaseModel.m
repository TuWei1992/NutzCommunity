//
//  BaseModel.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+(JSONKeyMapper*)keyMapper {
    JSONKeyMapper *mapper = [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
    return mapper;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    return [[[self class] alloc] initWithDictionary:dict error:nil];
}

@end

@implementation JSONValueTransformer (CustomTransformer)

- (NSString *)JSONObjectFromNSDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [formatter stringFromDate:date];
}

@end