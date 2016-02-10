//
//  URLCacheManager.m
//  NutzCommunity
//
//  Created by DuWei on 16/2/7.
//  Copyright © 2016年 nutz.cn. All rights reserved.
//

#import "URLCacheManager.h"
#import <CommonCrypto/CommonDigest.h>

#define CACHE_PATH [NSString stringWithFormat:@"%@/Documents/%@/", NSHomeDirectory(), @"webCache"]

@implementation URLCacheManager


+ (NSString *)md5String:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (instancetype)sharedCache
{
    static URLCacheManager *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[URLCacheManager alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:CACHE_PATH];
    });
    return _shareInstance;
}

- (BOOL)hasDataForURL:(NSString *)url
{
    NSString *cacheDirect = [self webCacheDirectPath];
    NSString *md5 = [URLCacheManager md5String:url];
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", cacheDirect, md5];
    
    BOOL isDirect = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDirect] && !isDirect) {
        return YES;
    }
    return NO;
}

- (NSString *)webCacheDirectPath {
    BOOL isDirect = NO;
    NSError *err = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:CACHE_PATH isDirectory:&isDirect] || !isDirect) {
        [[NSFileManager defaultManager] createDirectoryAtPath:CACHE_PATH withIntermediateDirectories:NO attributes:nil error:&err];
    }
    
    if (err) {
        NSLog(@"创建webcache目录失败%@", err);
    }
    return CACHE_PATH;
}

- (NSString *)getExtFromUrl:(NSString *)absoluteUrl
{
    NSString *pathString = absoluteUrl;
    NSString *ext = [pathString lastPathComponent];
    ext = [ext lowercaseString];
    NSRange rang = [ext rangeOfString:@"?"];
    if (rang.location != NSNotFound)
    {
        ext = [ext substringToIndex:rang.location];
    }
    rang = [ext rangeOfString:@"!"];
    if (rang.location != NSNotFound)
    {
        ext = [ext substringToIndex:rang.location];
    }
    ext = [ext pathExtension];
    return ext;
}


- (NSString *)getUrlWithParsUrl:(NSString *)absoluteUrl
{
    NSString *targetUrl = absoluteUrl;
    NSRange rang = [absoluteUrl rangeOfString:@"?"];
    if (rang.location != NSNotFound)
    {
        targetUrl = [targetUrl substringToIndex:rang.location];
    }
    return targetUrl;
}

- (NSData *)dataForURL:(NSString *)url {
    NSString *cacheDirect = [self webCacheDirectPath];
    NSString *md5 = [URLCacheManager md5String:url];
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", cacheDirect, md5];
    
    NSData *cacheData = [NSData dataWithContentsOfFile:cachePath];
    
#ifdef DEBUG
    NSLog(@"look for cachePath %@", cachePath);
    if (cacheData) {
        NSLog(@"exist cachePath %@", cachePath);
    }
#endif
    
    return cacheData;
}

- (void)storeData:(NSData *)data forURL:(NSString *)url
{
    NSString *cacheDirect = [self webCacheDirectPath];
    NSString *md5 = [URLCacheManager md5String:url];
    NSString *cachePath = [NSString stringWithFormat:@"%@%@", cacheDirect, md5];
    if(![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        BOOL isSuccess = [data writeToFile:cachePath atomically:YES];
        
#ifdef DEBUG
        if (!isSuccess) {
            NSLog(@"cache failed");
        }
        NSLog(@"store url %@ to %@", url, cachePath);
        if ([self hasDataForURL:url]) {
            NSLog(@"store success");
        }
#endif
    }
}

#pragma mark override method
- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    NSString *pathString = [[request URL] absoluteString];
    
    if ([self hasDataForURL:pathString]) {
        return;
    }
    
    NSLog(@"storeCachedResponse %@", pathString);
    if (![pathString containsString:@"/yvr/upload"]) {
        [super storeCachedResponse:cachedResponse forRequest:request];
        return;
    }
    
    [self storeData:cachedResponse.data forURL:pathString];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forDataTask:(NSURLSessionDataTask *)dataTask {
    NSString *pathString = [[dataTask.currentRequest URL] absoluteString];
    NSLog(@"storeCachedResponse forDataTask %@", pathString);
    
    if ([self hasDataForURL:pathString]) {
        return;
    }
    
    NSLog(@"storeCachedResponse %@", pathString);
    if (![pathString containsString:@"/yvr/upload"]) {
        [super storeCachedResponse:cachedResponse forDataTask:dataTask];
        return;
    }
    
    [self storeData:cachedResponse.data forURL:pathString];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"cachedResponseForRequest %@", request.URL.absoluteString);
    NSString *pathString = [[request URL] absoluteString];
    
    //nutz上传的图片
    if (![pathString containsString:@"/yvr/upload"]) {
        return [super cachedResponseForRequest:request];
    }
    
    if ([self hasDataForURL:pathString]) {
        NSData *data = [self dataForURL:pathString];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:@"image/jpg" expectedContentLength:[data length] textEncodingName:nil];
        return [[NSCachedURLResponse alloc] initWithResponse:response data:data];
    }
    
    return [super cachedResponseForRequest:request];
}


- (void)getCachedResponseForDataTask:(NSURLSessionDataTask *)dataTask completionHandler:(void (^) (NSCachedURLResponse * __nullable cachedResponse))completionHandler {
    
    NSString *pathString = [[dataTask.currentRequest URL] absoluteString];
    NSLog(@"getCachedResponseForDataTask forDataTask %@", pathString);
    
    if (![pathString containsString:@"/yvr/upload"]) {
        return [super getCachedResponseForDataTask:dataTask completionHandler:completionHandler];
    }
    
    if ([self hasDataForURL:pathString]) {
        NSData *data = [self dataForURL:pathString];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[dataTask.currentRequest URL] MIMEType:@"image/jpg" expectedContentLength:[data length] textEncodingName:nil];
        NSCachedURLResponse *resp = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        if(completionHandler)
        {
            completionHandler(resp);
        }
        return;
    }
    
    return [super getCachedResponseForDataTask:dataTask completionHandler:completionHandler];
}

@end
