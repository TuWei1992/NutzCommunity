//
//  APIClient.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/25.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "APIClient.h"

#define Code_CookieData      @"sessionCookies"

@implementation APIClient

+ (APIClient *)sharedClient {
    
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithHost:[NSURL URLWithString:MAIN_HOST]];
    });

    return _sharedClient;
}

- (id)initWithHost:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (!self) {
        return nil;
    }
    
    NSString *agent = [NSString stringWithFormat:@"NutzCN/%@ (iOS %@;%@)", VERSION_STRING, IOS_VERSION, VERSION_BUILD];
    
    self.responseSerializer                        = [AFJSONResponseSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", nil];
    
    [self.requestSerializer setValue:agent               forHTTPHeaderField:@"User-Agent"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"gzip, deflate"    forHTTPHeaderField:@"Accept-Encoding"];
    
    return self;
}



- (void)requestJSON:(NSString *)aPath
             params:(NSDictionary*)params
             method:(int)requestMethod
           callback:(void (^)(id data, NSError *error))block{
    [self requestJSON:aPath params:params method:requestMethod showError:YES callback:block];
}

- (void)requestJSON:(NSString *)aPath
             params:(NSDictionary*)params
             method:(int)requestMethod
          showError:(BOOL)showError
           callback:(void (^)(id data, NSError *error))block{
    if (!aPath || aPath.length <= 0) {
        return;
    }
    //log请求数据
    DEBUG_LOG(@"\n=========== Request ===========\n%@:\n%@", aPath, params);
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //发起请求
    switch (requestMethod) {
        case GET:{
            [self GET:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:showError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, error);
                !showError || [self showError:error];
                block(nil, error);
            }];
            break;
        }
        case POST:{
            [self POST:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:showError];
                if (error) {
                    block(nil, error);
                }
                block(responseObject, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, error);
                !showError || [self showError:error];
                block(nil, error);
            }];
            break;
        }
        case PUT:{
            [self PUT:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:showError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, error);
                !showError || [self showError:error];
                block(nil, error);
            }];
            break;
        }
        case DELETE:{
            [self DELETE:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:showError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, error);
                !showError || [self showError:error];
                block(nil, error);
            }];
        }
        default:
            break;
    }
    
}

-(void)requestJSON:(NSString *)aPath
              file:(NSDictionary *)file
            params:(NSDictionary *)params
            method:(int)requestMethod
          callback:(void (^)(id, NSError *))block{
    
    DEBUG_LOG(@"\n=========== Request ===========\n%@:\n%@", aPath, params);
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data;
    NSString *name, *fileName;
    
    if (file) {
        UIImage *image = file[@"image"];
        
        // 压缩
        data = UIImageJPEGRepresentation(image, 1.0);
        if ((float)data.length/1024 > 1000) {
            data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
        }
        
        name = file[@"name"];
        fileName = file[@"fileName"];
    }
    
    switch (requestMethod) {
        case POST:{
            
            AFHTTPRequestOperation *operation = [self POST:aPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                if (file) {
                    [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
                }
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DEBUG_LOG(@"\n=========== Response ===========\n%@:\n%@", aPath, error);
                [self showError:error];
                block(nil, error);
            }];
            [operation start];
            
            break;
        }
        default:
            break;
    }
}


+ (void)saveCookie {
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        // Here I see the correct rails session cookie
        DEBUG_LOG(@"\n=========== Save Cookie ===========\n%@", cookie);
    }
    
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:
                           [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: MAIN_HOST];
    [defaults synchronize];
    
}

+ (void)cleanCookie {
    NSURL *url = [NSURL URLWithString:MAIN_HOST];
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            DEBUG_LOG(@"\n=========== Clean Cookie ===========\n%@", cookie);
        }
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:Code_CookieData];
    [defaults synchronize];
}

- (void)uploadImage:(UIImage *)image
               path:(NSString *)path
               name:(NSString *)name
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
           progerss:(void (^)(CGFloat progressValue))progress{
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if ((float)data.length/1024 > 1000) {
        data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    // 这里可以加上用户ID
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg", @"", str];
    DEBUG_LOG(@"\nUploadImageSize\n%@ : %.0f", fileName, (float)data.length/1024);
    
    AFHTTPRequestOperation *operation = [self POST:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DEBUG_LOG(@"Success: %@ ***** %@", operation.responseString, responseObject);
        id error = [self handleResponse:responseObject];
        if (error && failure) {
            failure(operation, error);
        }else{
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DEBUG_LOG(@"Error: %@ ***** %@", operation.responseString, error);
        if (failure) {
            failure(operation, error);
        }
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        CGFloat progressValue = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (progress) {
            progress(progressValue);
        }
    }];
    [operation start];
}

#pragma mark 显示提示
- (NSString *)tipFromError:(NSError *)error {
    if (error && error.userInfo) {
        NSMutableString *tipStr = [[NSMutableString alloc] init];
        if ([error.userInfo objectForKey:@"msg"]) {
            NSArray *msgArray = [[error.userInfo objectForKey:@"msg"] allValues];
            NSUInteger num = [msgArray count];
            for (int i = 0; i < num; i++) {
                NSString *msgStr = [msgArray objectAtIndex:i];
                if (i+1 < num) {
                    [tipStr appendString:[NSString stringWithFormat:@"%@\n", msgStr]];
                }else{
                    [tipStr appendString:msgStr];
                }
            }
        }else{
            if ([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
                tipStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }else{
                [tipStr appendFormat:@"错误码%ld", (long)error.code];
            }
        }
        return tipStr;
    }
    return nil;
}

- (BOOL)showError:(NSError *)error {
    if ([JDStatusBarNotification isVisible]) {
        //如果statusBar上面正在显示信息，则不再用hud显示error
        return NO;
    }
    NSString *tipStr = [self tipFromError:error];
    [self showHudTipStr:tipStr];
    return YES;
}

- (void)showHudTipStr:(NSString *)tipStr {
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:KEY_WINDOW animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = tipStr;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.0];
    }
}

#pragma mark 处理错误
-(id)handleResponse:(id)responseJSON{
    return [self handleResponse:responseJSON autoShowError:YES];
}
-(id)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError{
    NSError *error = nil;
    
    //code为非0值时，表示有错
//    NSNumber *resultCode = [responseJSON valueForKeyPath:@"code"];
//    
//    if (resultCode.intValue != 0) {
//        error = [NSError errorWithDomain:MAIN_HOST code:resultCode.intValue userInfo:responseJSON];
//        if (autoShowError) {
//            [self showError:error];
//        }
//        
////        if (resultCode.intValue == 1000) {//用户未登录
////            [Login doLogout];
////            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
////        }
//        
//    }
    return error;
}

@end
