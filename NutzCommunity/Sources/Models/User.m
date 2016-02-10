//
//  User.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "User.h"
#import "AppSetup.h"

#define kLoginedUser @"logined_user"
static User *loginedUser;

@implementation User

+ (User *)loginedUser {
    if (!loginedUser) {
        NSDictionary *loginData = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginedUser];
        loginedUser = loginData ? [[User alloc] initWithDictionary:loginData] : nil;
    }
    return loginedUser;
}

+ (void)saveUser:(User *)user{
    if (user) {
        NSDictionary *dic = [user toDictionary];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dic forKey:kLoginedUser];
        loginedUser = nil;
        
        [defaults synchronize];
        //注册jpush
        [AppSetup setupJPush:nil];
    }else{
        [User logout];
    }
}


+ (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    loginedUser = nil;
    [defaults removeObjectForKey:kLoginedUser];
    [defaults synchronize];
    // 取消jpush
    [AppSetup closePush:nil];
}

+ (NSString *)userSign {
    if([FIND_DEFAULTS(kAppSign) boolValue]){
        return FIND_DEFAULTS(kAppSignContent);
    }else{
        return TOPIC_DEFAULT_SIGN;
    }
}

+ (BOOL)saveUserSign:(NSString *)sign {
    NSString *s = TRIM_STRING(sign);
    if(s.length == 0){
        TOAST_INFO(@"请先输入自定义签名");
        return NO;
    }
    
    if(s.length > 15){
        s = [s substringWithRange:NSMakeRange(0, 15)];
    }
    SYNC_DEFAULTS(s, kAppSignContent);
    return YES;
}

@end
