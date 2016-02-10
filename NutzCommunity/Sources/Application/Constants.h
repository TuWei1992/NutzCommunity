//
//  Constants.h
//  NutzCommunity
//
//  Created by DuWei on 15/12/22.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

// 开启debug
#define DEBUG_OPEN

// 图标字体
#define FONT_ICONS               @"FontAwesome"
// 默认字体
#define FONT_DEFAULE             @"AvenirNextCondensed-Regular"
#define FONT_DEFAULE_Light       @"AvenirNextCondensed-UltraLight"
#define FONT_DEFAULE_ITALIC      @"AvenirNextCondensed-Italic"
#define FONT_DEFAULE_BOLD        @"AvenirNextCondensed-Bold"
#define FONT_DEFAULE_BOLD_ITALIC @"AvenirNextCondensed-BoldItalic"

#define FONT_DEFAULT_SIZE(_size_)[UIFont fontWithName:FONT_DEFAULE size:_size_]
#define FONT_ICON_SIZE(_size_)   [UIFont fontWithName:FONT_ICONS   size:_size_]

// 侧滑菜单滑开后ContentView的X坐标相对于Screen的偏移量
#define SIDE_MENU_CENTERX_OFFSET 35.

// 导航栏标题字体大小
#define NAVBAR_FONT_SIZE         20.
#define NAVBAR_HEIGHT            64.


// 通知
#define APP_NOTIFICATION_UPDATE  @"AppNotificationUpdate"

//jpush
#define JPUSH_ENABLE_SETTING_KEY FORMAT_STRING(@"JPUSH_ENABLE_SETTING_%@", [User loginedUser].loginname)
#define JPUSH_ENABLE_SETTING_ON  @"YES"
#define JPUSH_ENABLE_SETTING_OFF @"NO"

//标语
#define NUTZ_SLOGAN              @"程序员小伙伴们的另一个选择"
