//
//  APIClient.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/25.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "API.h"

// 请求方法
typedef enum {
    GET = 0,
    POST,
    PUT,
    DELETE
} RequestMethod;

@interface APIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

// 保存Cookie数据
+ (void)saveCookie;
// 清除Cookie数据
+ (void)cleanCookie;

/**
 *  请求JSON数据
 *
 *  @param aPath         REST路径
 *  @param params        参数
 *  @param RequestMethod 请求方法
 *  @param callback      回调方法
 */
- (void)requestJSON:(NSString *)aPath
             params:(NSDictionary*)params
             method:(int)requestMethod
           callback:(void (^)(id data, NSError *error))callback;

/**
 *  请求JSON数据
 *
 *  @param aPath         REST路径
 *  @param params        参数
 *  @param RequestMethod 请求方法
 *  @param showError     错误的时候是否显示错误
 *  @param callback      回调方法
 */
- (void)requestJSON:(NSString *)aPath
             params:(NSDictionary*)params
             method:(int)requestMethod
          showError:(BOOL)showError
           callback:(void (^)(id data, NSError *error))block;

- (void)requestJSON:(NSString *)aPath
               file:(NSDictionary *)file
             params:(NSDictionary*)params
             method:(int)requestMethod
           callback:(void (^)(id data, NSError *error))block;

/**
 *  上传图片
 *
 *  @param image    图片
 *  @param path     REST路径
 *  @param name     图片Name
 *  @param params   额外参数
 *  @param success  成功回调
 *  @param failure  失败回调
 *  @param progress 进程回调
 */
- (void)uploadImage:(UIImage *)image
               path:(NSString *)path
               name:(NSString *)name
             params:(NSDictionary *)params
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
           progerss:(void (^)(CGFloat progressValue))progress;

@end
