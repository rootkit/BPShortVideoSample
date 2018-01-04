//
//  DGActivityIndicatorBallPulseAnimation.m
//  DGActivityIndicatorExample
//
//  Created by Nguyen Vinh on 7/19/15.
//  Copyright (c) 2015 Danil Gontovnik. All rights reserved.
//

#import "DGActivityIndicatorBallPulseAnimation.h"

@implementation DGActivityIndicatorBallPulseAnimation

- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat circlePadding = 7.0f;
    CGFloat circleSize = (size.width - 2 * circlePadding) / 3;
    CGFloat x = (layer.bounds.size.width - size.width) / 2;
    CGFloat y = (layer.bounds.size.height - circleSize) / 2;
    CGFloat duration = 0.3f;
    NSArray *timeBegins = @[@0.12f, @0.24f, @0.36f];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.3f);
    animation.toValue = @(1.0f);
    animation.duration = duration;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VAL;
    
    for (int i = 0; i < 3; i++) {
        CALayer *circle = [CALayer layer];
        
        circle.frame = CGRectMake(x + i * circleSize + i * circlePadding, y, circleSize, circleSize);
        circle.backgroundColor = tintColor.CGColor;
        circle.cornerRadius = circle.bounds.size.width / 2;
        animation.beginTime = [timeBegins[i] floatValue];
        [circle addAnimation:animation forKey:@"animation"];
        [layer addSublayer:circle];
    }
}

@end
