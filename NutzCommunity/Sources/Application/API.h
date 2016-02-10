//
//  API.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/25.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#ifndef API_h
#define API_h
#endif

// 每次请求的条数
#define NUTZ_PAGE_SIZE           12

#define MAIN_HOST                @"http://nutz.cn"
#define MAIN_HOST_HTTPS          @"https://nutz.cn"
#define NUTZ_CDN_HOST            @"https://dn-nutzcn.qbox.me"
#define NUTZ_API_PREFIX_TOPIC    @"/yvr/t/"
#define NUTZ_API_PREFIX_API      @"/yvr/api/v1" //不需要加/结尾
#define NUTZ_API_PREFIX_USER     @"/yvr/user/"
#define NUTZ_API_PREFIX_IMAGES   @"/yvr/upload/"

#define NUTZ_REST_API(_S_, ...)  [NSString stringWithFormat:(@"/yvr/api/v1"_S_), ##__VA_ARGS__]

#define NUTZ_API_TOPICS          NUTZ_API_PREFIX_API@"/topics"
#define NUTZ_API_TOKEN           NUTZ_API_PREFIX_API@"/accesstoken"
#define NUTZ_API_USER            NUTZ_API_PREFIX_API@"/user"
#define NUTZ_API_IMAGES          NUTZ_API_PREFIX_API@"/images"