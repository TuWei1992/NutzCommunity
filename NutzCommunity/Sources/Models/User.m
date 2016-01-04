//
//  User.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/19.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "User.h"

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
        loginedUser = [[User alloc] initWithDictionary:dic];
        
        [defaults synchronize];
    }else{
        [User logout];
    }
}


+ (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kLoginedUser];
    [defaults synchronize];
}

@end
