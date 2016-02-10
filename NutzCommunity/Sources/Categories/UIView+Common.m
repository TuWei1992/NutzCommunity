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
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGRect bounds = CGRectInset(self.bounds, 0, 0);
    
    CGPathAddRect(pathRef, nil, bounds);
    
    layer.path = pathRef;
    
    CFRelease(pathRef);
    if (self.backgroundColor) {
        layer.fillColor = self.backgroundColor.CGColor;//layer的填充色用cell原本的颜色
    }else{
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    }
    
    CGColorRef lineColor = [UIColor colorWithWhite:0.85 alpha:1.000].CGColor;
    
    [self layer:layer addLineUp:YES andLong:YES andColor:lineColor andBounds:bounds withLeftSpace:0];
    
    [self.layer insertSublayer:layer atIndex:0];
}

- (void)addBottomLineWidthLeftSpace:(CGFloat)leftSpace {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGRect bounds = CGRectInset(self.bounds, 0, 0);
    
    CGPathAddRect(pathRef, nil, bounds);
    
    layer.path = pathRef;
    
    CFRelease(pathRef);
    if (self.backgroundColor) {
        layer.fillColor = self.backgroundColor.CGColor;//layer的填充色用cell原本的颜色
    }else{
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    }
    
    CGColorRef lineColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
    
    [self layer:layer addLineUp:NO andLong:YES andColor:lineColor andBounds:bounds withLeftSpace:0];
    
    [self.layer insertSublayer:layer atIndex:0];}

- (void)layer:(CALayer *)layer addLineUp:(BOOL)isUp andLong:(BOOL)isLong andColor:(CGColorRef)color andBounds:(CGRect)bounds withLeftSpace:(CGFloat)leftSpace{
    
    CALayer *lineLayer = [[CALayer alloc] init];
    CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
    CGFloat left, top;
    if (isUp) {
        top = 0;
    }else{
        top = bounds.size.height-lineHeight;
    }
    
    if (isLong) {
        left = 0;
    }else{
        left = leftSpace;
    }
    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+left, top, bounds.size.width-left, lineHeight);
    lineLayer.backgroundColor = color;
    [layer addSublayer:lineLayer];
}


@end
