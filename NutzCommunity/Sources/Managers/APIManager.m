//
//  APIManager.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/25.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "APIManager.h"
#import "APIClient.h"

@interface APIManager()

@property (nonatomic, strong) APIClient *client;

@end

static int PageSize = 20;

@implementation APIManager

+ (instancetype)manager {
    static APIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[APIManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self){
        self.client = [APIClient sharedClient];
    }
    return self;
}

- (id)parseData:(NSDictionary *)jsonData{
    if(jsonData){
        return jsonData[@"data"];
    }
    return nil;
}

- (void)topicsByTab:(NSString *)tab
               page:(int)page
           callback:(void (^)(NSArray* topics, NSError *error))block{
    NSDictionary *param = @{
                            @"page"      : @(page),
                            @"mdrender"  : @"false",
                            @"limit"     : @(PageSize),
                            @"tab"       : tab
                            };
    [self.client requestJSON: NUTZ_API_TOPICS
                      params: param method: GET callback: ^(id data, NSError *error) {
        NSArray *topics = [self parseData:data];
        if(topics) {
            NSMutableArray *array = [NSMutableArray new];
            for(NSDictionary *t in topics) {
                [array addObject:[[Topic alloc] initWithDictionary:t]];
            }
            block(array, nil);
        } else {
            block(nil, error);
        }
        
    }];
    
}


- (void)topicDetailById:(NSString *)topicId
               callback:(void (^)(Topic* topicDtail, NSError *error))block {

    [self.client requestJSON: NUTZ_REST_API(@"/topic/%@", topicId)
                      params: @{@"mdrender" : @"true"}
                      method: GET callback: ^(id data, NSError *error) {
        NSDictionary *topic = [self parseData:data];
        if(topic) {
            block([[Topic alloc] initWithDictionary:topic], nil);
        } else {
            block(nil, error);
        }
        
    }];

}

- (void)likeReplyById:(NSString *)replyId
          accessToken:(NSString *)accessToken
             callback:(void (^)(NSString* likeType, NSError *error))block{
    
    [self.client requestJSON:NUTZ_REST_API(@"/reply/%@/ups", replyId)
                      params:@{@"accessToken" : accessToken}
                      method:GET callback:^(id data, NSError *error) {
        if([data[@"success"] boolValue]){
            block(data[@"action"], nil);
        }else{
            block(nil, [NSError errorWithDomain:MAIN_HOST code:-1
                                       userInfo:@{@"message" : data[@"message"]}]);
        }
    }];
}


@end
