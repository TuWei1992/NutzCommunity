//
//  UIView+Line.m
//  NutzCommunity
//
//  Created by DuWei on 15/12/23.
//  Copyright (c) 2015年 nutz.cn. All rights reserved.
//

#import "UIView+Common.h"

@implementation UIView (Common)

- (void)addTopLineWidthLeftSpace:(CGFloat)leftSpace {
    CGContextRef context = UIGraphicsGetCurrentContext();//获得当前view的图形上下文(context)
    
    CGContextSetLineWidth(context, 0.5);//制定了线的宽度
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.3, 0.3, 0.3, 1.0};//颜色元素
    CGColorRef color=CGColorCreate(colorspace,components);//这两行创建颜色
    CGContextSetStrokeColorWithColor(context, color);//使用刚才创建好的颜色为上下文设置颜色
    
    CGContextMoveToPoint(context, 0, 1);//设置线段的起始点
    CGContextAddLineToPoint(context, self.frame.size.width, 1);//设置线段的终点
    
    CGContextStrokePath(context);//绘制
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}

- (void)addBottomLineWidthLeftSpace:(CGFloat)leftSpace {
    CGContextRef context = UIGraphicsGetCurrentContext();//获得当前view的图形上下文(context)
    
    CGContextSetLineWidth(context, 0.5);//制定了线的宽度
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.3, 0.3, 0.3, 1.0};//颜色元素
    CGColorRef color=CGColorCreate(colorspace,components);//这两行创建颜色
    CGContextSetStrokeColorWithColor(context, color);//使用刚才创建好的颜色为上下文设置颜色
    
    CGContextMoveToPoint(context, 0, self.frame.size.height - 1);//设置线段的起始点
    CGContextAddLineToPoint(context, self.frame.size.width, self.bounds.origin.x);//设置线段的终点
    
    CGContextStrokePath(context);//绘制
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

@end
