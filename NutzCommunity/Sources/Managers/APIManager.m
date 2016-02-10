//
//  APIManager.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/25.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "APIManager.h"

@interface APIManager()

@end

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

//===========================
// API Methods
//===========================

- (void)userInfoByToken:(NSString *)accessToken
               callback:(void (^)(User* user, NSError *error))block{
    
    NSDictionary *param = @{@"accesstoken" : accessToken};
    [self.client requestJSON: NUTZ_API_TOKEN
                      params: param method: GET callback: ^(id data, NSError *error) {
        User *userInfo = [[User alloc] initWithDictionary:data];
        if(userInfo) {
            userInfo.accessToken = accessToken;
            
            // 详细信息
            [self.client requestJSON:NUTZ_REST_API(@"/user/%@", userInfo.loginname)
                              params:nil
                              method:GET
                            callback:^(id data2, NSError *error2) {
                                User *detail = [[User alloc] initWithDictionary:[self parseData:data2]];
                                if(detail){
                                    detail.ID = userInfo.ID;
                                    detail.accessToken = accessToken;
                                }else{
                                    detail = userInfo;
                                }
                                block(detail, nil);
                            }];
        } else {
            block(nil, error);
        }
    }];
}

- (void)userDetailInfoByName:(NSString *)userName callback:(void (^)(User* user, NSError *error))block {
    // 详细信息
    [self.client requestJSON:NUTZ_REST_API(@"/user/%@", userName)
                      params:nil
                      method:GET
                    callback:^(id data2, NSError *error2) {
                        User *detail = [[User alloc] initWithDictionary:[self parseData:data2]];
                        block(detail, nil);
                    }];
}

- (void)topicsByTab:(NSString *)tab
               page:(int)page
           callback:(void (^)(NSArray* topics, NSError *error))block{
    NSDictionary *param = @{
                            @"page"      : @(page),
                            @"mdrender"  : @"false",
                            @"limit"     : @(NUTZ_PAGE_SIZE),
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
                      params:@{@"accesstoken" : accessToken}
                      method:POST callback:^(id data, NSError *error) {
        if(!error){
            block(data[@"success"], nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)newTopic:(NSString*)title
         tabType:(NSString*)tab
         content:(NSString*)content
     accessToken:(NSString*)accessToken
        callback:(void (^)(NSString* topicId, NSError *error))block{
    [JDStatusBarNotification showStatusBarActivity:@"发布中..."];
    NSDictionary *parameters = @{@"accesstoken":accessToken, @"tab":tab, @"title":title, @"content":content};
    [self.client requestJSON:NUTZ_API_TOPICS params:parameters method:POST callback:^(id data, NSError *error) {
        if(!error){
            [JDStatusBarNotification showStatusBarSuccess:@"发布成功"];
            block(data[@"topic_id"], nil);
        }else{
            [JDStatusBarNotification showStatusBarError:error];
            block(nil, error);
        }
    }];
}

- (void)replyTopicById:(NSString*)ID
               content:(NSString*)content
               replyId:(NSString *)replyId
           accessToken:(NSString*)accessToken
              callback:(void (^)(NSString* replyId, NSError *error))block{
    [JDStatusBarNotification showStatusBarActivity:@"发布中..."];
    
    NSDictionary *parameters = @{@"accesstoken":accessToken, @"content":content, @"reply_id":replyId};
    [self.client requestJSON:NUTZ_REST_API(@"/topic/%@/replies", ID) params:parameters method:POST callback:^(id data, NSError *error) {
        if(!error){
            [JDStatusBarNotification showStatusBarSuccess:@"发布成功"];
            block(data[@"reply_id"], nil);
        }else{
            [JDStatusBarNotification showStatusBarError:error];
            block(nil, error);
        }
    }];
    
}

- (void)uploadImage:(UIImage*)image
        accessToken:(NSString *)accessToken
           callback:(void (^)(NSString* imageUrl, NSError *error))block
           progerss:(void (^)(CGFloat progressValue))progress{
    [self.client uploadImage:image
                        path:NUTZ_REST_API(@"/images?accesstoken=%@", accessToken)
                        name:@"file"
                      params:nil
                     success:^(AFHTTPRequestOperation *operation, id data) {
                         if(data){
                             if([data[@"success"] boolValue]){
                                 block(data[@"url"], nil);
                                 return;
                             }
                         }
                         block(nil, [NSError errorWithDomain:MAIN_HOST code:-1
                                                        userInfo:@{@"message" : @"图片上传失败"}]);
                         
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         block(nil, error);
                         
                     } progerss:^(CGFloat progressValue) {
                         if(progress){
                             progress(progressValue);
                         }
                     }];
}

@end
