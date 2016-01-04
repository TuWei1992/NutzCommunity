//
//  ObjcRuntime.h
///  CSMBP
//
//  Created by 杨辉 on 14-1-20.
//  Copyright (c) 2014年 Forever OpenSource Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//根据类名称获取类
//系统就提供 NSClassFromString(NSString *clsname)

void Swizzle(Class c, SEL origSEL, SEL newSEL);