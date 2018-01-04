//
//  UIView+highlightOnTouch.m
//
//  Created by Simon Westerlund on 15/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "UIView+highlightOnTouch.h"
#import <objc/runtime.h>

static char *const kSWHighlightOnTouchKey;
static float opacityWhenHighlighted = 0.5f;
static NSTimeInterval animateDuration = 0.3;

@implementation UIView (highlightOnTouch)

- (BOOL)shouldHightlightOnTouch {
    NSNumber *number = objc_getAssociatedObject(self, kSWHighlightOnTouchKey);
    return [number boolValue];
}

- (void)setHighlightOnTouch:(BOOL)highlightOnTouch {
    NSNumber *number = [NSNumber numberWithBool:highlightOnTouch];
    objc_setAssociatedObject(self, kSWHighlightOnTouchKey, number, OBJC_ASSOCIATION_ASSIGN);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if ([self shouldHightlightOnTouch]) {
        [self.layer setOpacity:opacityWhenHighlighted];
        [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
            [layer setOpacity:opacityWhenHighlighted];
        }];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if ([self shouldHightlightOnTouch]) {
        [self fadeOutAnimated:NO];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if ([self shouldHightlightOnTouch]) {
        [self fadeOutAnimated:YES];
    }
}

- (void)fadeOutAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated ? animateDuration : 0.1 animations:^{
        [self setAlpha:1.0f];
        [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            [view setAlpha:1.0f];
        }];
    }];
}

@end
