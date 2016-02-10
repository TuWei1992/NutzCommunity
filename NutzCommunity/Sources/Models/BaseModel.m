//
//  BaseModel.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "BaseModel.h"

@implementation JSONValueTransformer (CustomTransformer)

- (NSDate *)NSDateFromNSString:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *dt = [formatter dateFromString:string];
    return dt;
}

- (NSString *)JSONObjectFromNSDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+0000"];
    NSString *dt = [formatter stringFromDate:date];
    return dt;
}

@end

@implementation BaseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+ (JSONKeyMapper*)keyMapper{
    // json dic 键值对映射
    JSONKeyMapper *mapper = [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase] withExceptions:@{@"id" : @"ID"}];
    return mapper;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    return [[[self class] alloc] initWithDictionary:dict error:nil];
}

@end

