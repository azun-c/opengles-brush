//
//  DraggableView.m
//  i-Reporter
//
//  Created by 高津 洋一 on 13/01/07.
//  Copyright (c) 2013 CIMTOPS CORPORATION. All rights reserved.
//

#import "DraggableView.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DraggableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.prevPoint = CGPointZero;
        self.dragging = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.delegate = nil;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGRect ellipseRect = rect;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor grayColor] setStroke];
	CGContextSetLineWidth(context, 5.0f);
    const CGFloat dashStyle[] = {4.0};
    CGContextSetLineDash(context, 0.0, dashStyle, 1);
    
    float dx = 0.2 * ellipseRect.size.width;
    float dy = 0.2 * ellipseRect.size.height;
    CGRect insetRect = CGRectInset(ellipseRect, dx, dy);
    
    CGContextStrokeEllipseInRect(context, insetRect);    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    self.dragging = YES;

    self.prevPoint = [[touches anyObject] locationInView:self.superview];
    if ([self.delegate respondsToSelector:@selector(draggableViewBeginMoving:)]) {
        [self.delegate draggableViewBeginMoving:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    if (self.dragging) {
        CGPoint point = [[touches anyObject] locationInView:self.superview];
        CGFloat dx = point.x - self.prevPoint.x;
        CGFloat dy = point.y - self.prevPoint.y;

        CGPoint center = CGPointMake(self.center.x + dx, self.center.y + dy);
        // superviewのはみ出しチェック
        if (!CGRectContainsPoint(self.superview.frame, center)) {
            float minX = CGRectGetMinX(self.superview.frame);
            float maxX = CGRectGetMaxX(self.superview.frame);
            float minY = CGRectGetMinY(self.superview.frame);
            float maxY = CGRectGetMaxY(self.superview.frame);
            
            if (center.x < minX) {
                center.x = minX;
            }
            if (maxX < center.x) {
                center.x = maxX;
            }
            if (center.y < minY) {
                center.y = minY;
            }
            if (maxY < center.y) {
                center.y = maxY;
            }
        }
        self.center = center;
        
        self.prevPoint = point;
        
        if ([self.delegate respondsToSelector:@selector(draggableViewMoving:)]) {
            [self.delegate draggableViewMoving:self];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(nullable UIEvent *)event {
    self.dragging = NO;
    
    if ([self.delegate respondsToSelector:@selector(draggableViewEndMoving:)]) {
        [self.delegate draggableViewEndMoving:self];
    }
}

@end
NS_ASSUME_NONNULL_END
