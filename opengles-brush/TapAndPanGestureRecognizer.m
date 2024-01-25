//
//  TapAndPanGestureRecognizer.m
//  i-Reporter
//
//  Created by 高津 洋一 on 2015/09/28.
//  Copyright (c) 2015 CIMTOPS CORPORATION. All rights reserved.
//

#import "TapAndPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN
@implementation TapAndPanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.state = UIGestureRecognizerStatePossible;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if (touch.tapCount != 2) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.state = UIGestureRecognizerStateBegan;
    
    CGPoint oldPoint = [touch previousLocationInView:self.view];
    CGPoint newPoint = [touch locationInView:self.view];
    
    // 移動量
    self.translation = CGPointMake(newPoint.x - oldPoint.x, newPoint.y - oldPoint.y);
    
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    switch (self.state) {
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:
            self.state = UIGestureRecognizerStateFailed;
            break;
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            self.state = UIGestureRecognizerStateEnded;
            break;
        default:
            self.state = UIGestureRecognizerStateCancelled;
            break;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self reset];
    
    self.state = UIGestureRecognizerStateFailed;
}

- (void)reset {
    [super reset];
    
    self.translation = CGPointZero;
}

@end
NS_ASSUME_NONNULL_END
